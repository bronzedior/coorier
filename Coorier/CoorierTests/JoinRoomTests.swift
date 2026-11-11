//
//  JoinRoomTests.swift
//  CoorierTests
//

import Foundation
import Testing
@testable import Coorier

@MainActor
struct JoinRoomTests {
    private let service = MockRoomService()

    private func hostedRoom(_ seal: RoomSeal = .blueQuill) -> HostRoomViewModel {
        let host = HostRoomViewModel(seal: seal, roomService: service)
        host.openRoom()
        return host
    }

    /// Typed codes are checked against the network before joining, so the result arrives a moment later.
    private func waitFor(_ condition: () -> Bool) async throws {
        for _ in 0..<50 where !condition() {
            try await Task.sleep(for: .milliseconds(20))
        }
    }

    private func typeCode(_ text: String, into viewModel: JoinRoomViewModel) {
        viewModel.showCodeEntry()
        viewModel.updateCode(text)
    }

    @Test func nothingHostedHereAcceptsWhatItDecoded() {
        #expect(service.join(seal: .violetCrown, code: nil) == .joined)
        #expect(service.join(seal: .violetCrown, code: RoomCode.make(seal: .violetCrown)) == .joined)
    }

    @Test func hostedRoomAcceptsItsOwnSealAndExactCode() {
        let host = hostedRoom()
        #expect(service.join(seal: host.seal, code: nil) == .joined)
        #expect(service.join(seal: host.seal, code: host.code) == .joined)
    }

    @Test func hostedRoomRejectsOtherSealAndWrongCodeTail() throws {
        let host = hostedRoom()
        #expect(service.join(seal: .amberAnchor, code: nil) == .rejected)

        let wrongTail = try #require(RoomCode(text: String(format: "%04d", (host.code.value + 1) % 10_000)))
        #expect(service.join(seal: wrongTail.seal ?? host.seal, code: wrongTail) == .rejected)
    }

    @Test func everySealJoinsByScanAndByCode() async throws {
        for seal in RoomSeal.allCases {
            let host = hostedRoom(seal)
            let viewModel = JoinRoomViewModel(roomService: service)

            viewModel.simulateScan(of: seal)
            #expect(viewModel.joinedRoom == JoinedRoom(seal: seal, code: nil))

            let other = JoinRoomViewModel(roomService: service)
            typeCode(host.code.text, into: other)
            try await waitFor { other.joinedRoom != nil }
            #expect(other.joinedRoom == JoinedRoom(seal: seal, code: host.code))
        }
    }

    @Test func leavingTheHostPageStopsRejectingOtherRooms() {
        let host = hostedRoom(.blueQuill)
        #expect(service.join(seal: .crimsonKey, code: nil) == .rejected)

        host.closeRoom()
        #expect(service.join(seal: .crimsonKey, code: nil) == .joined)
    }

    @Test func wrongStampShowsMismatchAlert() {
        _ = hostedRoom(.blueQuill)
        let viewModel = JoinRoomViewModel(roomService: service)
        viewModel.simulateScan(of: .crimsonKey)
        #expect(viewModel.joinAlert == .stampMismatch)
    }

    @Test func wrongCodeShowsErrorInsteadOfAlert() async throws {
        let host = hostedRoom()
        let viewModel = JoinRoomViewModel(roomService: service)
        let wrong = String(format: "%04d", (host.code.value + 1) % 10_000)
        typeCode(wrong, into: viewModel)
        try await waitFor { viewModel.codeError != nil }
        #expect(viewModel.codeError != nil)
        #expect(viewModel.joinAlert == nil)
        #expect(viewModel.joinedRoom == nil)
    }

    @Test func wrongCodeClearsTheDigitsSoTheNextCodeCanBeTyped() async throws {
        let host = hostedRoom()
        let viewModel = JoinRoomViewModel(roomService: service)
        typeCode(String(format: "%04d", (host.code.value + 1) % 10_000), into: viewModel)
        try await waitFor { viewModel.codeError != nil }
        #expect(viewModel.codeError != nil)

        try await Task.sleep(for: .milliseconds(700))
        #expect(viewModel.codeText.isEmpty)

        viewModel.updateCode(host.code.text)
        try await waitFor { viewModel.joinedRoom != nil }
        #expect(viewModel.joinedRoom == JoinedRoom(seal: host.seal, code: host.code))
    }

    @Test func aCodeNobodyIsHostingDoesNotJoin() async throws {
        let host = hostedRoom(.blueQuill)
        let viewModel = JoinRoomViewModel(roomService: service)
        // A well-formed code for another seal: it decodes fine, but no one is hosting it.
        let stranger = RoomCode.make(seal: .violetCrown)
        #expect(stranger != host.code)
        typeCode(stranger.text, into: viewModel)
        try await waitFor { viewModel.codeError != nil }
        #expect(viewModel.codeError == "No room with this code")
        #expect(viewModel.joinedRoom == nil)
    }

    @Test func pinchZoomStaysInsideTheZoomRange() {
        let viewModel = JoinRoomViewModel(roomService: service)
        viewModel.pinchZoom(by: 100)
        #expect(viewModel.zoom == ARSealScanner.zoomRange.upperBound)
        viewModel.endPinch()
        viewModel.pinchZoom(by: 0.001)
        #expect(viewModel.zoom == ARSealScanner.zoomRange.lowerBound)
    }
}
