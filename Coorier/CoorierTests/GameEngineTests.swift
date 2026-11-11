//
//  GameEngineTests.swift
//  CoorierTests
//

import Foundation
import Testing
@testable import Coorier

/// Deterministic random numbers so every failing seed can be replayed.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58_476D_1CE4_E5B9
        value = (value ^ (value >> 27)) &* 0x94D0_49BB_1331_11EB
        return value ^ (value >> 31)
    }
}

@MainActor
struct GameEngineTests {
    private func makeGame(players: Int, seed: UInt64 = 1) throws -> GameState {
        var rng = SeededGenerator(state: seed)
        let seats = (0..<players).map { "p\($0)" }
        let photos = Dictionary(uniqueKeysWithValues: zip(seats, Bird.allCases.map(\.photo)))
        return try #require(GameEngine.start(seats: seats, photos: photos, using: &rng))
    }

    private func request(of member: MemberID, in state: GameState) throws -> LetterColor {
        try #require(state.birds[member]).request
    }

    @Test func birdPairsWantEachOthersColor() {
        for bird in Bird.allCases {
            let partner = Bird.allCases.first { $0.color == bird.request }
            #expect(partner?.request == bird.color)
            #expect(bird.request != bird.color)
        }
    }

    @Test func avatarPhotosMapToTheirBird() {
        #expect(Bird(photo: "Photo1-Uru") == .blue)
        #expect(Bird(photo: "Photo8-Aru") == .purple)
        #expect(Bird(photo: "") == nil)
    }

    @Test(arguments: 2...8)
    func dealNeverGivesPlayersTheirRequestedColor(players: Int) throws {
        for seed in 1...200 {
            let state = try makeGame(players: players, seed: UInt64(seed))
            let everyItem = state.items + state.pending
            for seat in state.seats {
                let want = try request(of: seat, in: state)
                for round in 1...GameState.mailsPerPlayer {
                    let hand = everyItem.filter { $0.holder == seat && $0.round == round }
                    let mail = try #require(hand.first { $0.isMail })
                    let letter = try #require(hand.first { $0.isLetter })
                    #expect(hand.count == 2)
                    #expect(mail.color != want && letter.color != want, "seed \(seed)")
                    if players == 2 {
                        #expect(mail.color == letter.color, "seed \(seed)")
                    } else {
                        #expect(mail.color != letter.color, "seed \(seed)")
                    }
                    #expect(letter.isLetter)
                }
            }
        }
    }

    @Test(arguments: 2...8)
    func everyRequestIsDealtExactlyOncePerRound(players: Int) throws {
        let state = try makeGame(players: players, seed: 7)
        let requests = try state.seats.map { try request(of: $0, in: state) }.sorted { $0.rawValue < $1.rawValue }
        for round in 1...GameState.mailsPerPlayer {
            let items = (state.items + state.pending).filter { $0.round == round }
            let mails = items.filter(\.isMail).map(\.color).sorted { $0.rawValue < $1.rawValue }
            let letters = items.filter(\.isLetter).map(\.color).sorted { $0.rawValue < $1.rawValue }
            #expect(mails == requests)
            #expect(letters == requests)
        }
        #expect(state.items.allSatisfy { $0.round == 1 })
    }

    @Test func tooFewPlayersCannotStart() {
        var rng = SeededGenerator(state: 1)
        #expect(GameEngine.start(seats: ["a"], photos: [:], using: &rng) == nil)
    }

    @Test func duplicateOrMissingAvatarsStillGiveUniqueBirds() {
        let birds = GameEngine.assignBirds(seats: ["a", "b", "c"], photos: ["a": "Photo1-Uru", "b": "Photo1-Uru"])
        #expect(birds["a"] == .blue)
        #expect(Set(birds.values).count == 3)
    }

    @Test func leftIsTheNextSeatClockwise() throws {
        let state = try makeGame(players: 4)
        #expect(state.neighbor(of: "p0", .left) == "p1")
        #expect(state.neighbor(of: "p0", .right) == "p3")
        #expect(state.neighbor(of: "p3", .left) == "p0")
    }

    @Test func readyLettersAndMailCanBePassedImmediately() throws {
        var state = try makeGame(players: 4)
        let hand = state.items(heldBy: "p0")
        let letter = try #require(hand.first { $0.isLetter })
        let mail = try #require(hand.first { $0.isMail })

        try GameEngine.apply(.pass(item: letter.id, direction: .right), by: "p0", to: &state)
        #expect(state.item(letter.id)?.holder == "p3")
        #expect(state.item(letter.id)?.arrivedFrom == .left)

        try GameEngine.apply(.pass(item: mail.id, direction: .left), by: "p0", to: &state)
        #expect(state.item(mail.id)?.holder == "p1")
        #expect(state.item(mail.id)?.arrivedFrom == .right)
    }

    @Test func onlyTheHolderCanActOnAnItem() throws {
        var state = try makeGame(players: 3)
        let mail = try #require(state.items(heldBy: "p0").first { $0.isMail })
        #expect(throws: GameRejection.notYourItem) {
            try GameEngine.apply(.pass(item: mail.id, direction: .left), by: "p1", to: &state)
        }
    }

    @Test func wrongCombinationIsRejected() throws {
        var state = try makeGame(players: 3)
        let hand = state.items(heldBy: "p0")
        let letter = try #require(hand.first { $0.isLetter })
        let mail = try #require(hand.first { $0.isMail })
        #expect(throws: GameRejection.wrongCombination) {
            try GameEngine.apply(.combine(letter: letter.id, mail: mail.id), by: "p0", to: &state)
        }
    }

    /// Anyone can seal a matching pair and pass it on, but only the bird that asked for it takes it.
    @Test func sealedMailForAnotherBirdCanBePassedButNotDelivered() throws {
        var state = try makeGame(players: 4)
        // Hand p0 a matching letter and mail that p0's bird does not want, as if neighbours passed them.
        let want = try request(of: "p0", in: state)
        let letter = try #require(state.items.first { $0.isLetter && $0.color != want })
        let mail = try #require(state.items.first { $0.isMail && $0.color == letter.color })
        for id in [letter.id, mail.id] {
            var item = try #require(state.item(id))
            item.holder = "p0"
            state.replace(item)
        }
        try GameEngine.apply(.combine(letter: letter.id, mail: mail.id), by: "p0", to: &state)
        #expect(state.item(mail.id)?.isSealed == true)

        #expect(throws: GameRejection.notYourMail) {
            try GameEngine.apply(.deliver(item: mail.id), by: "p0", to: &state)
        }
        try GameEngine.apply(.pass(item: mail.id, direction: .left), by: "p0", to: &state)
        #expect(state.item(mail.id)?.holder == "p1")
    }

    @Test(arguments: 2...8)
    func aFullGameFinishesWithTwoMailsEach(players: Int) throws {
        var state = try makeGame(players: players, seed: UInt64(players))
        var steps = 0
        while !state.isFinished {
            steps += 1
            try #require(steps < 10_000, "game did not finish")
            try playOneStep(&state)
        }
        #expect(state.items.isEmpty && state.pending.isEmpty)
        #expect(state.seats.allSatisfy { state.sentCount(for: $0) == GameState.mailsPerPlayer })
        #expect(throws: GameRejection.gameOver) {
            try GameEngine.apply(.deliver(item: 1), by: "p0", to: &state)
        }
    }

    /// A simple player: deliver its own mail, seal any matching pair, otherwise pass anything not ours to the left.
    private func playOneStep(_ state: inout GameState) throws {
        for seat in state.seats {
            let want = try request(of: seat, in: state)
            let hand = state.items(heldBy: seat)
            if let sealed = hand.first(where: { $0.isSealed && $0.color == want }) {
                return try GameEngine.apply(.deliver(item: sealed.id), by: seat, to: &state)
            }
            if let letter = hand.first(where: { letter in letter.isLetter && hand.contains { $0.isMail && $0.color == letter.color } }),
               let mail = hand.first(where: { $0.isMail && $0.color == letter.color }) {
                return try GameEngine.apply(.combine(letter: letter.id, mail: mail.id), by: seat, to: &state)
            }
            if let stranger = hand.first(where: { $0.color != want }) {
                return try GameEngine.apply(.pass(item: stranger.id, direction: .left), by: seat, to: &state)
            }
        }
        // Everyone holds only their own color but not a full pair yet: impossible if dealing is right.
        Issue.record("no player could move")
        throw GameRejection.unknownItem
    }

    @Test(arguments: 2...8)
    func seatingRingVisitsEverySeatOnce(players: Int) {
        let ring = SeatingModel.ring(count: players)
        #expect(ring.sorted() == Array(0..<players))
    }

    @Test(arguments: 2...8)
    func hostAlwaysOccupiesTheBottomMiddleSeat(players: Int) throws {
        let host = RoomMember(id: "host", name: "Host", photo: Bird.blue.photo)
        let guests = (1..<players).map { index in
            RoomMember(id: "guest-\(index)", name: "Guest \(index)", photo: Bird.allCases[index].photo)
        }

        let seated = SeatingModel.placingHost(guests + [host], hostID: host.id)
        let hostIndex = try #require(SeatingModel.hostIndex(count: players))

        #expect(seated[hostIndex].id == host.id)
    }

    @Test func hostSeatCannotBeSwapped() throws {
        let viewModel = SeatingViewModel(playerCount: 4)
        let hostID = try #require(viewModel.hostPlayerID)
        let host = try #require(viewModel.players.first { $0.id == hostID })
        let guest = try #require(viewModel.players.first { $0.id != hostID })
        let original = viewModel.players

        viewModel.swap(host, with: guest)

        #expect(viewModel.players == original)
        #expect(viewModel.playerAt(row: 3, column: 2)?.id == hostID)
    }

    @Test func gameStateSurvivesTheWire() throws {
        let state = try makeGame(players: 5)
        let decoded = try JSONDecoder().decode(GameState.self, from: JSONEncoder().encode(state))
        #expect(decoded == state)
    }
}
