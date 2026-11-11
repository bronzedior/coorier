//
//  WaitingViewModel.swift
//  Coorier
//

import Observation

@Observable
final class WaitingViewModel {
    static let maxDots = 3

    var playerCount: Int

    private(set) var dotCount = 1

    var isExitConfirmationPresented = false

    init(playerCount: Int = 2) {
        self.playerCount = playerCount
    }

    var playersText: String {
        "(\(playerCount)/\(HostRoomViewModel.maxPlayers))"
    }

    func advanceDots() {
        dotCount = dotCount % Self.maxDots + 1
    }

    func requestExit() {
        isExitConfirmationPresented = true
    }
}
