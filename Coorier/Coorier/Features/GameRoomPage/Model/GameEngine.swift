//
//  GameEngine.swift
//  Coorier
//

import Foundation

nonisolated enum GameRejection: Error, Equatable {
    case gameOver
    case unknownItem
    case notYourItem
    case noNeighbor
    case wrongCombination
    case notSealed
    case notYourMail
}

nonisolated enum GameEngine {
    static let minPlayers = 2

    static func start(
        seats: [MemberID],
        photos: [MemberID: String],
        using rng: inout some RandomNumberGenerator
    ) -> GameState? {
        guard seats.count >= minPlayers, seats.count <= Bird.allCases.count, Set(seats).count == seats.count else {
            return nil
        }
        let birds = assignBirds(seats: seats, photos: photos)
        var state = GameState(seats: seats, birds: birds)

        var nextID = 1
        for round in 1...GameState.mailsPerPlayer {
            for (seat, pair) in zip(seats, dealPairs(count: seats.count, using: &rng)) {
                let mailColor = birds[seats[pair.mail]]?.request ?? .blue
                let letterColor = birds[seats[pair.letter]]?.request ?? .blue
                let mail = GameItem(id: nextID, color: mailColor, round: round, kind: .mail, holder: seat)
                let letter = GameItem(
                    id: nextID + 1,
                    color: letterColor,
                    round: round,
                    kind: .letter,
                    holder: seat
                )
                nextID += 2
                if round == 1 {
                    state.items += [mail, letter]
                } else {
                    state.pending += [mail, letter]
                }
            }
        }
        return state
    }

    static func assignBirds(seats: [MemberID], photos: [MemberID: String]) -> [MemberID: Bird] {
        var birds: [MemberID: Bird] = [:]
        var taken = Set<Bird>()
        for seat in seats {
            guard let bird = photos[seat].flatMap(Bird.init(photo:)), !taken.contains(bird) else { continue }
            birds[seat] = bird
            taken.insert(bird)
        }
        var spare = Bird.allCases.filter { !taken.contains($0) }
        for seat in seats where birds[seat] == nil && !spare.isEmpty {
            birds[seat] = spare.removeFirst()
        }
        return birds
    }

    static func dealPairs(count: Int, using rng: inout some RandomNumberGenerator) -> [(mail: Int, letter: Int)] {
        let seats = Array(0..<count)
        if count == 2 {
            return seats.map { seat in
                let other = (seat + 1) % count
                return (other, other)
            }
        }
        for _ in 0..<64 {
            let mails = seats.shuffled(using: &rng)
            guard seats.allSatisfy({ mails[$0] != $0 }) else { continue }
            for _ in 0..<64 {
                let letters = seats.shuffled(using: &rng)
                if seats.allSatisfy({ letters[$0] != $0 && letters[$0] != mails[$0] }) {
                    return seats.map { (mails[$0], letters[$0]) }
                }
            }
        }
        return seats.map { (($0 + 1) % count, ($0 + 2) % count) }
    }
}
