//
//  JoinRoomViewModel.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 23/10/26.
//

import AVFoundation
import Observation
import RealityKit
import SwiftUI

@Observable
final class JoinRoomViewModel {
    enum ScanState: Equatable {
        case idle
        case scanning
        case found(RoomSeal)
        case denied
        case unavailable
    }

    static let placeholderSeal: RoomSeal = .crimsonKey

    private(set) var scanState: ScanState = .idle
    private(set) var zoomOptions: [CGFloat] = []
    private(set) var zoom: CGFloat = 1

    var isCodeEntryPresented = false
    var codeText = ""
    private(set) var codeError: String?
    private(set) var isCheckingCode = false
    private(set) var joinAlert: JoinAlert?
    private(set) var joinedRoom: JoinedRoom?

    @ObservationIgnored private var isRejectingCode = false
    @ObservationIgnored private var scanner: ARSealScanner?
    @ObservationIgnored private var pinchStartZoom: CGFloat?
    @ObservationIgnored private let roomService: RoomService

    init(roomService: RoomService = NetworkRoomService.shared) {
        self.roomService = roomService
    }

    var cameraView: ARView? {
        scanState == .scanning ? scanner?.view : nil
    }

    var statusText: String? {
        switch scanState {
        case .idle, .scanning: nil
        case .found(let seal): "Found the \(seal.accessibilityName.lowercased())!"
        case .denied: "Camera access is off. Allow it in Settings, or join with code."
        case .unavailable: "No camera here. Join with code instead."
        }
    }

    func startScanning() async {
        guard joinedRoom == nil else { return }
        guard ARSealScanner.isCameraAvailable else {
            scanState = .unavailable
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            guard await AVCaptureDevice.requestAccess(for: .video) else {
                scanState = .denied
                return
            }
        default:
            scanState = .denied
            return
        }

        let scanner = scanner ?? makeScanner()
        self.scanner = scanner
        scanState = .scanning
        zoomOptions = scanner.start()
        zoom = 1
        if zoomOptions.isEmpty {
            scanState = .unavailable
        }
    }

    func stopScanning() {
        scanner?.stop()
        if scanState == .scanning {
            scanState = .idle
        }
    }

    func setZoom(_ factor: CGFloat) {
        applyZoom(factor, animated: true)
    }

    func pinchZoom(by magnification: CGFloat) {
        let start = pinchStartZoom ?? zoom
        pinchStartZoom = start
        applyZoom(start * magnification, animated: false)
    }

    func endPinch() {
        pinchStartZoom = nil
    }

    private func applyZoom(_ factor: CGFloat, animated: Bool) {
        let clamped = min(max(factor, ARSealScanner.zoomRange.lowerBound), ARSealScanner.zoomRange.upperBound)
        if animated {
            withAnimation(.easeOut(duration: 0.25)) { zoom = clamped }
        } else {
            zoom = clamped
        }
    }

    func showCodeEntry() {
        codeText = ""
        codeError = nil
        isCodeEntryPresented = true
        stopScanning()
    }

    func dismissCodeEntry() {
        isCodeEntryPresented = false
        if scanState == .idle, joinedRoom == nil {
            Task { await startScanning() }
        }
    }

    func updateCode(_ text: String) {
        guard !isRejectingCode, !isCheckingCode else { return }
        codeText = String(text.filter(\.isASCII).filter(\.isNumber).prefix(RoomCode.length))
        codeError = nil
        if codeText.count == RoomCode.length {
            submitCode()
        }
    }

    private func submitCode() {
        guard let code = RoomCode(text: codeText), let seal = code.seal else {
            rejectCode()
            return
        }
        isCheckingCode = true
        Task {
            let exists = await roomService.roomExists(code: code)
            isCheckingCode = false
            guard isCodeEntryPresented, joinedRoom == nil else { return }
            if exists {
                joinRoom(seal: seal, code: code)
            } else {
                rejectCode(message: "No room with this code")
            }
        }
    }

    func simulateScan(of seal: RoomSeal) {
        handleScan(seal)
    }

    func resetScan() {
        scanState = .idle
        Task { await startScanning() }
    }

    private func handleScan(_ seal: RoomSeal) {
        scanner?.stop()
        scanState = .found(seal)
        joinRoom(seal: seal, code: nil)
    }

    private func joinRoom(seal: RoomSeal, code: RoomCode?) {
        switch roomService.join(seal: seal, code: code) {
        case .joined:
            codeText = ""
            joinedRoom = JoinedRoom(seal: seal, code: code)
        case .rejected:
            if code == nil {
                joinAlert = .stampMismatch
            } else {
                rejectCode()
            }
        }
    }

    private func rejectCode(message: String = "That code doesn't look right") {
        codeError = message
        isRejectingCode = true
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            codeText = ""
            isRejectingCode = false
        }
    }

    func dismissJoinAlert() {
        joinAlert = nil
        if case .found = scanState {
            resetScan()
        }
    }

    private func makeScanner() -> ARSealScanner {
        ARSealScanner { [weak self] sealIndex in
            guard let self, let seal = RoomSeal(rawValue: sealIndex) else { return }
            handleScan(seal)
        }
    }
}
