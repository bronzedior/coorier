//
//  GameState.swift
//  Coorier
//

import Foundation

nonisolated enum GameIntent: Codable, Sendable, Equatable {
    case pass(item: Int, direction: PassDirection)
    case combine(letter: Int, mail: Int)
    case deliver(item: Int)
}

nonisolated struct GameState: Codable, Sendable, Equatable {
    static let title = "Adulting 101"
    static let mailsPerPlayer = 2

    let seats: [MemberID]
    let birds: [MemberID: Bird]
    var items: [GameItem] = []
    var pending: [GameItem] = []
    var sent: [MemberID: Int] = [:]

    var isFinished: Bool {
        seats.allSatisfy { sentCount(for: $0) >= Self.mailsPerPlayer }
    }

    func sentCount(for member: MemberID) -> Int {
        sent[member, default: 0]
    }

    func items(heldBy member: MemberID) -> [GameItem] {
        items.filter { $0.holder == member }
    }

    func item(_ id: Int) -> GameItem? {
        items.first { $0.id == id }
    }

    func neighbor(of member: MemberID, _ direction: PassDirection) -> MemberID? {
        guard let index = seats.firstIndex(of: member), seats.count > 1 else { return nil }
        let step = direction == .left ? 1 : seats.count - 1
        return seats[(index + step) % seats.count]
    }
}
