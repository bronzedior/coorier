//
//  NetworkGameService.swift
//  Coorier
//

import Foundation

final class NetworkGameService: GameService {
    private let room: NetworkRoomService

    init(room: NetworkRoomService = .shared) {
        self.room = room
    }

    var state: GameState? { room.session.game }
    var myID: MemberID { room.session.localMember.id }

    func send(_ intent: GameIntent) {
        room.session.send(intent)
    }

    func leave() {
        room.leave()
    }
}
