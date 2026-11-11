//
//  HostRoomViewModel.swift
//  Coorier
//

import Observation

@Observable
final class HostRoomViewModel {
    static let minPlayers = GameEngine.minPlayers
    static let maxPlayers = Bird.allCases.count

    private(set) var seal: RoomSeal
    private(set) var code: RoomCode

    @ObservationIgnored private let roomService: RoomService

    var playerCount: Int

    var isCodePopupPresented = false

    init(seal: RoomSeal = .random(), playerCount: Int = 1, roomService: RoomService = NetworkRoomService.shared) {
        self.seal = seal
        self.code = .make(seal: seal)
        self.playerCount = playerCount
        self.roomService = roomService
    }

    func openRoom() {
        roomService.publish(seal: seal, code: code)
    }

    var canStart: Bool {
        playerCount >= Self.minPlayers
    }

    var playersText: String {
        "(\(playerCount)/\(Self.maxPlayers))"
    }

    var inviteMessage: String {
        canStart ? "Ask your friends to join you." : "Gather your crew to get started!"
    }

    func showCodePopup() {
        isCodePopupPresented = true
    }

    func dismissCodePopup() {
        isCodePopupPresented = false
    }

    func regenerateRoom() {
        seal = .random()
        code = .make(seal: seal)
        roomService.publish(seal: seal, code: code)
    }

    func closeRoom() {
        roomService.unpublish()
    }
}
