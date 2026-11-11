//
//  RoomMessages.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 26/10/26.
//

import Foundation

typealias MemberID = String

nonisolated struct RoomMember: Codable, Sendable, Hashable, Identifiable {
    let id: MemberID
    var name: String
    var photo: String
}

nonisolated enum RoomPhase: String, Codable, Sendable {
    case lobby
    case seating
    case playing
    case end
}

nonisolated struct RoomSnapshot: Codable, Sendable, Equatable {
    var phase: RoomPhase = .lobby
    let hostID: MemberID
    var members: [RoomMember]
    var game: GameState?
}

nonisolated enum ClientMessage: Codable, Sendable {
    case hello(RoomMember)
    case updateProfile(RoomMember)
    case game(GameIntent)
    case ping
}

nonisolated enum ServerMessage: Codable, Sendable {
    case snapshot(RoomSnapshot)
    case roomFull
}
