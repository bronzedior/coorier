//
//  GameNetworkTests.swift
//  CoorierTests
//

import Foundation
import Testing
@testable import Coorier

/// One host and two guests on the real peer-to-peer stack (Bonjour + TCP on this machine):
/// the host deals, a guest's move travels to the host and the new state comes back to everyone.
@MainActor
struct GameNetworkTests {
    private func waitUntil(_ timeout: Duration = .seconds(15), _ condition: () -> Bool) async throws {
        let deadline = ContinuousClock.now + timeout
        while !condition() {
            try #require(ContinuousClock.now < deadline, "timed out")
            try await Task.sleep(for: .milliseconds(100))
        }
    }

    @Test func startingAfterSeatingDealsTheGameImmediately() async throws {
        let host = RoomSession()
        let guests = [RoomSession(), RoomSession()]
        let seal = RoomSeal.random()
        let code = RoomCode.make(seal: seal)
        defer {
            host.leave()
            guests.forEach { $0.leave() }
        }
        try #require(host.isSupported, "needs iOS 26 networking")

        host.host(seal: seal, code: code)
        host.updateProfile(name: "Host", photo: Bird.blue.photo)
        for (index, guest) in guests.enumerated() {
            guest.join(.code(code))
            guest.updateProfile(name: "Guest \(index)", photo: Bird.allCases[index + 1].photo)
        }
        try await waitUntil { host.members.count == 3 && guests.allSatisfy { $0.members.count == 3 } }

        host.startSeating()
        try await waitUntil { guests.allSatisfy { $0.phase == .seating } }
        let hostSeat = try #require(SeatingModel.hostIndex(count: host.members.count))
        #expect(host.members[hostSeat].id == host.localMember.id)
        #expect(guests.allSatisfy { $0.members[hostSeat].id == host.localMember.id })
        host.startGame()
        try await waitUntil { guests.allSatisfy { $0.phase == .playing && $0.game != nil } }
        #expect(host.phase == .playing)
        #expect(host.game != nil)
    }

    @Test func aGuestsPassReachesTheHostAndEveryoneSeesIt() async throws {
        let host = RoomSession()
        let guests = [RoomSession(), RoomSession()]
        let seal = RoomSeal.random()
        let code = RoomCode.make(seal: seal)
        defer {
            host.leave()
            guests.forEach { $0.leave() }
        }
        try #require(host.isSupported, "needs iOS 26 networking")

        host.host(seal: seal, code: code)
        host.updateProfile(name: "Host", photo: Bird.blue.photo)
        for (index, guest) in guests.enumerated() {
            guest.join(.code(code))
            guest.updateProfile(name: "Guest \(index)", photo: Bird.allCases[index + 1].photo)
        }
        try await waitUntil { host.members.count == 3 && guests.allSatisfy { $0.members.count == 3 } }

        host.startGame()
        try await waitUntil { guests.allSatisfy { $0.game != nil && $0.phase == .playing } }
        #expect(guests[0].game == host.game)

        // Guest 0 passes its mail to the left; the host applies it and broadcasts.
        let guest = guests[0]
        let mover = guest.localMember.id
        let game = try #require(guest.game)
        let hand = game.items(heldBy: mover)
        let mail = try #require(hand.first { $0.isMail })
        let receiver = try #require(game.neighbor(of: mover, .left))
        guest.send(.pass(item: mail.id, direction: .left))

        try await waitUntil { host.game?.item(mail.id)?.holder == receiver }
        try await waitUntil { guests.allSatisfy { $0.game?.item(mail.id)?.holder == receiver } }

        // Ready letters use the same network pass flow as mail.
        let letter = try #require(hand.first { $0.isLetter })
        guest.send(.pass(item: letter.id, direction: .left))
        try await waitUntil { host.game?.item(letter.id)?.holder == receiver }
        try await waitUntil { guests.allSatisfy { $0.game?.item(letter.id)?.holder == receiver } }
    }
}
