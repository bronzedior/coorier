//
//  GameEngine+Rules.swift
//  Coorier
//

import Foundation

nonisolated extension GameEngine {
    static func apply(_ intent: GameIntent, by member: MemberID, to state: inout GameState) throws(GameRejection) {
        guard !state.isFinished else { throw .gameOver }
        switch intent {
        case let .pass(id, direction):
            try pass(id, direction, by: member, in: &state)
        case let .combine(letterID, mailID):
            try combine(letterID, into: mailID, by: member, in: &state)
        case let .deliver(id):
            try deliver(id, by: member, in: &state)
        }
    }

    static func combineRejection(letter: GameItem, mail: GameItem, by member: MemberID) -> GameRejection? {
        guard letter.holder == member, mail.holder == member else { return .notYourItem }
        guard letter.isLetter, mail.isMail else { return .wrongCombination }
        guard letter.color == mail.color else { return .wrongCombination }
        return nil
    }

    static func deliverRejection(_ item: GameItem, by member: MemberID, in state: GameState) -> GameRejection? {
        guard item.holder == member else { return .notYourItem }
        guard item.isSealed else { return .notSealed }
        guard item.color == state.birds[member]?.request else { return .notYourMail }
        return nil
    }

    private static func owned(_ id: Int, by member: MemberID, in state: GameState) throws(GameRejection) -> GameItem {
        guard let item = state.item(id) else { throw .unknownItem }
        guard item.holder == member else { throw .notYourItem }
        return item
    }

    private static func pass(_ id: Int, _ direction: PassDirection, by member: MemberID, in state: inout GameState) throws(GameRejection) {
        var item = try owned(id, by: member, in: state)
        guard let target = state.neighbor(of: member, direction) else { throw .noNeighbor }
        item.holder = target
        item.arrivedFrom = direction.opposite
        state.replace(item)
    }

    private static func combine(_ letterID: Int, into mailID: Int, by member: MemberID, in state: inout GameState) throws(GameRejection) {
        let letter = try owned(letterID, by: member, in: state)
        var mail = try owned(mailID, by: member, in: state)
        if let rejection = combineRejection(letter: letter, mail: mail, by: member) { throw rejection }
        mail.kind = .sealed
        state.items.removeAll { $0.id == letterID }
        state.replace(mail)
    }

    private static func deliver(_ id: Int, by member: MemberID, in state: inout GameState) throws(GameRejection) {
        let item = try owned(id, by: member, in: state)
        if let rejection = deliverRejection(item, by: member, in: state) { throw rejection }
        state.items.removeAll { $0.id == id }
        let sent = state.sentCount(for: member) + 1
        state.sent[member] = sent
        let released = state.pending.filter { $0.holder == member && $0.round == sent + 1 }
        state.pending.removeAll { item in released.contains { $0.id == item.id } }
        state.items += released
    }
}

nonisolated extension GameState {
    mutating func replace(_ item: GameItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
    }
}
