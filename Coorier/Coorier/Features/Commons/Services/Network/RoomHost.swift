//
//  RoomHost.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 26/10/26.
//

import Foundation
import Network

@available(iOS 26.0, *)
@MainActor
final class RoomHost {
    private final class Peer {
        var memberID: MemberID?
        var lastHeard = Date()
        var isClosed = false
        let outbox: AsyncStream<ServerMessage>.Continuation
        
        init(outbox: AsyncStream<ServerMessage>.Continuation) {
            self.outbox = outbox
        }
    }
    
    var onChange: (RoomSnapshot) -> Void = { _ in }
    var onPermissionDenied: () -> Void = {}
    
    private(set) var snapshot: RoomSnapshot
    private let seal: RoomSeal
    private let code: RoomCode
    private var peers: [MemberID: Peer] = [:]
    private var task: Task<Void, Never>?
    
    init(hostMember: RoomMember, seal: RoomSeal, code: RoomCode) {
        self.snapshot = RoomSnapshot(hostID: hostMember.id, members: [hostMember])
        self.seal = seal
        self.code = code
    }
    
    func start() {
        guard task == nil else { return }
        onChange(snapshot)
        task = Task {
            await withTaskGroup { group in
                group.addTask { await self.keepListening() }
                group.addTask { await self.heartbeat() }
            }
        }
    }
    
    func stop() {
        task?.cancel()
        task = nil
        for peer in peers.values { peer.isClosed = true }
        peers = [:]
    }
    
    func swapSeats(_ first: MemberID, _ second: MemberID) {
        guard first != snapshot.hostID, second != snapshot.hostID else { return }
        guard let firstIndex = snapshot.members.firstIndex(where: { $0.id == first }),
              let secondIndex = snapshot.members.firstIndex(where: { $0.id == second }) else { return }
        update { $0.members.swapAt(firstIndex, secondIndex) }
    }
    
    func setPhase(_ phase: RoomPhase) {
        update { $0.phase = phase }
    }

    func startGame() {
        guard snapshot.game == nil else { return }
        let members = snapshot.members
        let seats = SeatingModel.ring(count: members.count).map { members[$0].id }
        let photos = Dictionary(uniqueKeysWithValues: members.map { ($0.id, $0.photo) })
        var rng = SystemRandomNumberGenerator()
        guard let game = GameEngine.start(seats: seats, photos: photos, using: &rng) else { return }
        update {
            $0.game = game
            $0.phase = .playing
        }
    }

    func apply(_ intent: GameIntent, by member: MemberID) {
        guard var game = snapshot.game else { return }
        do {
            try GameEngine.apply(intent, by: member, to: &game)
            update { $0.game = game }
            if game.isFinished, snapshot.phase == .playing {
                update { $0.phase = .end }
            }
        } catch {
            return
        }
    }

    func updateProfile(_ member: RoomMember) {
        guard let index = snapshot.members.firstIndex(where: { $0.id == member.id }) else { return }
        var member = member
        let others = snapshot.members.filter { $0.id != member.id }
        if !member.photo.isEmpty, others.contains(where: { $0.photo == member.photo }) {
            member.photo = snapshot.members[index].photo
        }
        if !member.name.isEmpty, others.contains(where: { $0.name.lowercased() == member.name.lowercased() }) {
            member.name = snapshot.members[index].name
            member.photo = snapshot.members[index].photo
        }
        update { $0.members[index] = member }
    }
    
    private func update(_ change: (inout RoomSnapshot) -> Void) {
        let old = snapshot
        change(&snapshot)
        if snapshot.phase == .seating {
            snapshot.members = SeatingModel.placingHost(snapshot.members, hostID: snapshot.hostID)
        }
        guard snapshot != old else { return }
        onChange(snapshot)
        for peer in peers.values { peer.outbox.yield(.snapshot(snapshot)) }
    }
    
    private func join(_ member: RoomMember, peer: Peer) {
        let isKnown = snapshot.members.contains { $0.id == member.id }
        guard isKnown || snapshot.members.count < RoomWire.maxMembers else {
            peer.outbox.yield(.roomFull)
            return
        }
        peer.memberID = member.id
        peers[member.id]?.isClosed = true
        peers[member.id] = peer
        if isKnown {
            updateProfile(member)
        } else {
            update { $0.members.append(member) }
        }
        peer.outbox.yield(.snapshot(snapshot))
    }
    
    private func leave(_ id: MemberID) {
        guard snapshot.phase == .lobby else { return }
        update { $0.members.removeAll { $0.id == id } }
    }
    
    private func keepListening() async {
        while !Task.isCancelled {
            try? await listen()
            try? await Task.sleep(for: .seconds(1))
        }
    }
    
    private func listen() async throws {
        let txtRecord = NWTXTRecord([RoomWire.sealKey: String(seal.rawValue), RoomWire.codeKey: code.text])
        let listener = try NetworkListener(
            for: .bonjour(name: "Coorier \(code.text)", type: RoomWire.service, txtRecord: txtRecord),
            using: .reliable(ServerMessage.self, ClientMessage.self)
        ).onStateUpdate { [weak self] _, state in self?.onListenerState(state) }
        try await listener.run { [weak self] connection in
            await self?.serve(connection)
        }
    }
    
    private func onListenerState(_ state: NetworkListener<some NetworkProtocolOptions>.State) {
        switch state {
        case .waiting(let error), .failed(let error):
            if RoomWire.isPermissionDenied(error) { onPermissionDenied() }
        default:
            break
        }
    }
    
    private func serve(_ connection: NetworkConnection<RoomHostCoder>) async {
        let (outbox, continuation) = AsyncStream.makeStream(of: ServerMessage.self)
        let peer = Peer(outbox: continuation)
        let sender = Task {
            for await message in outbox {
                do { try await connection.send(message) } catch { peer.isClosed = true; return }
            }
        }
        let receiver = Task {
            do {
                for try await message in connection.messages {
                    peer.lastHeard = Date()
                    handle(message.content, from: peer)
                }
            } catch {}
            peer.isClosed = true
        }
        while !peer.isClosed, !Task.isCancelled, Date().timeIntervalSince(peer.lastHeard) < RoomWire.silenceLimit {
            try? await Task.sleep(for: .milliseconds(250))
        }
        receiver.cancel()
        sender.cancel()
        continuation.finish()
        peer.isClosed = true
        if let id = peer.memberID, peers[id] === peer {
            peers[id] = nil
            leave(id)
        }
    }
    
    private func handle(_ message: ClientMessage, from peer: Peer) {
        switch message {
        case .hello(let member):
            guard peer.memberID == nil, member.id != snapshot.hostID else { return }
            join(member, peer: peer)
        case .updateProfile(let member):
            guard peer.memberID == member.id else { return }
            updateProfile(member)
        case .game:
            guard let member = peer.memberID else { return }
            handle(playerMessage: message, from: member)
        case .ping:
            break
        }
    }

    private func handle(playerMessage message: ClientMessage, from member: MemberID) {
        switch message {
        case .game(let intent): apply(intent, by: member)
        case .hello, .updateProfile, .ping: break
        }
    }
    
    private func heartbeat() async {
        while !Task.isCancelled {
            for peer in peers.values where peer.memberID != nil {
                peer.outbox.yield(.snapshot(snapshot))
            }
            try? await Task.sleep(for: RoomWire.heartbeat)
        }
    }
}
