//
//  ChooseAvatarViewModel.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 24/10/26.
//

import SwiftUI

@Observable
final class ChooseAvatarViewModel {
    private(set) var name = ""
    private(set) var photoIndex = 0
    private(set) var shakeCount = 0
    private(set) var prohibitedShakeCount = 0
    private(set) var isConfirmed = false
    private(set) var sway: Double = 0
    private(set) var swing: Double = 0
    private(set) var slide: CGFloat = 0
    private(set) var contentFrame: CGRect = .zero

    var takenAvatars: Set<Int> = []
    private(set) var takenNames: Set<String> = []

    private var swayTask: Task<Void, Never>?
    private var swapTask: Task<Void, Never>?
    private var isSwapping = false
    private let model = ChooseAvatarModel()

    private let swayAngle: Double = 2
    private let swayHalfPeriod: Double = 1.5

    private let swapExitTravel: CGFloat = 440
    private let swapEnterTravel: CGFloat = 300
    private let swapExitDuration: Double = 0.17
    private let swapExitAngle: Double = 14
    private let swapEnterAngle: Double = 24
    private let swapLockDuration: Double = 0.4
    private let swayPauseDuration: Double = 0.4

    var photos: [String] { model.photos }
    var currentPhoto: String { model.photos[photoIndex] }
    var displayName: String { model.displayName(name) }
    var isCurrentPhotoTaken: Bool { takenAvatars.contains(photoIndex) }
    var isNameTaken: Bool { model.isTaken(name, by: takenNames) }
    var canConfirm: Bool { !name.isEmpty && !isCurrentPhotoTaken && !isNameTaken }

    func updateName(_ newName: String) {
        name = model.sanitized(newName)
    }

    func takeNames(_ names: [String]) {
        takenNames = Set(names.filter { !$0.isEmpty }.map { $0.lowercased() })
        if isConfirmed, isNameTaken {
            unconfirm()
            shake()
        }
    }

    func updateContentFrame(_ frame: CGRect) {
        guard abs(frame.minY - contentFrame.minY) > 0.5 || abs(frame.height - contentFrame.height) > 0.5 else { return }
        contentFrame = frame
    }

    func takeAvatars(claimedBy photos: [String]) {
        takenAvatars = Set(photos.compactMap { model.photos.firstIndex(of: $0) })
        if isConfirmed, isCurrentPhotoTaken {
            unconfirm()
            shake()
        }
    }

    func toggleCurrentPhotoTaken() {
        if !takenAvatars.insert(photoIndex).inserted {
            takenAvatars.remove(photoIndex)
        }
    }

    func cyclePhoto(_ direction: Int) {
        guard !isSwapping else { return }
        isSwapping = true
        swapTask = Task {
            await swap(direction)
            try? await Task.sleep(for: .seconds(swapLockDuration - swapExitDuration))
            isSwapping = false
        }
    }

    private func swap(_ direction: Int) async {
        let side = Double(direction)

        withAnimation(.easeIn(duration: swapExitDuration)) {
            slide = -CGFloat(direction) * swapExitTravel
            swing = -side * swapExitAngle
        }
        try? await Task.sleep(for: .seconds(swapExitDuration))
        guard !Task.isCancelled else { return }

        var jump = Transaction()
        jump.disablesAnimations = true
        withTransaction(jump) {
            photoIndex = (photoIndex + direction + model.photos.count) % model.photos.count
            slide = CGFloat(direction) * swapEnterTravel
            swing = -side * swapEnterAngle
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
            slide = 0
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.3)) {
            swing = 0
        }
    }

    func shake() {
        withAnimation(.default) {
            if name.isEmpty {
                shakeCount += 1
            }
            if isCurrentPhotoTaken {
                prohibitedShakeCount += 1
            }
        }
    }

    func confirm() {
        guard canConfirm else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            isConfirmed = true
        }
    }

    func unconfirm() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isConfirmed = false
        }
    }

    func startSway() {
        swayTask?.cancel()
        swayTask = Task {
            withAnimation(.easeInOut(duration: swayHalfPeriod / 2)) {
                sway = -swayAngle
            }
            try? await Task.sleep(for: .seconds(swayHalfPeriod / 2 + 0.05))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: swayHalfPeriod).repeatForever(autoreverses: true)) {
                sway = swayAngle
            }
        }
    }

    func pauseSway() {
        swayTask?.cancel()
        withAnimation(.easeInOut(duration: swayPauseDuration)) {
            sway = 0
        }
    }

    func stopSway() {
        swayTask?.cancel()
        swapTask?.cancel()
        isSwapping = false
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) {
            sway = 0
            swing = 0
            slide = 0
        }
    }
}
