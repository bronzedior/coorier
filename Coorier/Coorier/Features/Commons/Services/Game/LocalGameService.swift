//
//  LocalGameService.swift
//  Coorier
//

import Foundation
import Observation

@Observable
final class LocalGameService: GameService {
    private(set) var state: GameState?
    private(set) var members: [RoomMember]
    var myID: MemberID {
        didSet { bots.forget(myID) }
    }
    var botsEnabled = true
    var botsPlayMySeat = false

    @ObservationIgnored private var bots = GameBots()
    @ObservationIgnored private var task: Task<Void, Never>?

    private static let names = ["You", "Bella", "Citra", "Dodi", "Eka", "Fajar", "Gita", "Hana"]

    init(playerCount: Int = 4, myBird: Bird = .blue) {
        let members = Self.makeMembers(count: playerCount, myBird: myBird)
        self.members = members
        myID = members[0].id
        restart()
    }

    func restart(playerCount: Int) {
        let myBird = state?.birds[myID] ?? .blue
        members = Self.makeMembers(count: playerCount, myBird: myBird)
        myID = members[0].id
        restart()
    }

    private static func makeMembers(count: Int, myBird: Bird) -> [RoomMember] {
        let count = min(max(count, GameEngine.minPlayers), Bird.allCases.count)
        let birds = [myBird] + Bird.allCases.filter { $0 != myBird }
        return (0..<count).map { index in
            RoomMember(id: "local-\(index)", name: names[index], photo: birds[index].photo)
        }
    }

    private func restart() {
        var rng = SystemRandomNumberGenerator()
        let photos = Dictionary(uniqueKeysWithValues: members.map { ($0.id, $0.photo) })
        state = GameEngine.start(seats: members.map(\.id), photos: photos, using: &rng)
        bots = GameBots()
        startBots()
    }

    func send(_ intent: GameIntent) {
        apply(intent, by: myID)
    }

    func leave() {
        task?.cancel()
        task = nil
    }

    private func apply(_ intent: GameIntent, by member: MemberID) {
        guard var next = state else { return }
        do {
            try GameEngine.apply(intent, by: member, to: &next)
            state = next
        } catch {
        }
    }

    private func startBots() {
        task?.cancel()
        task = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(350))
                guard let self else { return }
                self.tickBots()
            }
        }
    }

    private func tickBots() {
        guard botsEnabled, let state, !state.isFinished else { return }
        for seat in state.seats where seat != myID || botsPlayMySeat {
            if let intent = bots.nextMove(for: seat, in: state) {
                apply(intent, by: seat)
                return
            }
        }
    }
}
