//
//  GameBots.swift
//  Coorier
//

import Foundation

struct GameBots {
    private var readyAt: [MemberID: Date] = [:]

    mutating func forget(_ seat: MemberID) {
        readyAt[seat] = nil
    }

    mutating func nextMove(for seat: MemberID, in state: GameState, now: Date = Date()) -> GameIntent? {
        if let ready = readyAt[seat], ready > now { return nil }
        guard let want = state.birds[seat]?.request else { return nil }
        let hand = state.items(heldBy: seat)

        if let sealed = hand.first(where: { $0.isSealed && $0.color == want }) {
            return paced(.deliver(item: sealed.id), seat, now)
        }
        if let letter = hand.first(where: { letter in letter.isLetter && hand.contains { $0.isMail && $0.color == letter.color } }),
           let mail = hand.first(where: { $0.isMail && $0.color == letter.color }) {
            return paced(.combine(letter: letter.id, mail: mail.id), seat, now)
        }
        if let stranger = hand.first(where: { $0.color != want }),
           let direction = Self.shortestWay(from: seat, to: stranger.color, in: state) {
            return paced(.pass(item: stranger.id, direction: direction), seat, now)
        }
        return nil
    }

    private mutating func paced(_ intent: GameIntent, _ seat: MemberID, _ now: Date) -> GameIntent {
        readyAt[seat] = now + .random(in: 0.8...1.8)
        return intent
    }

    static func shortestWay(from seat: MemberID, to color: LetterColor, in state: GameState) -> PassDirection? {
        guard let from = state.seats.firstIndex(of: seat),
              let target = state.seats.firstIndex(where: { state.birds[$0]?.request == color }) else { return nil }
        let count = state.seats.count
        let stepsLeft = (target - from + count) % count
        return stepsLeft <= count - stepsLeft ? .left : .right
    }
}
