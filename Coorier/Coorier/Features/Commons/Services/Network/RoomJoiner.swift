//
//  RoomJoiner.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 26/10/26.
//

import Foundation
import Network

enum RoomInvite: Equatable {
    case seal(RoomSeal)
    case code(RoomCode)

    var txtMatch: (key: String, value: String) {
        switch self {
        case .seal(let seal): (RoomWire.sealKey, String(seal.rawValue))
        case .code(let code): (RoomWire.codeKey, code.text)
        }
    }
}

@available(iOS 26.0, *)
@MainActor
final class RoomJoiner {
    var onSnapshot: (RoomSnapshot) -> Void = { _ in }
    var onConnectedChange: (Bool) -> Void = { _ in }
    var onRoomFull: () -> Void = {}
    var onPermissionDenied: () -> Void = {}

    private let invite: RoomInvite
    private var localMember: RoomMember
    private var outbox: AsyncStream<ClientMessage>.Continuation?
    private var task: Task<Void, Never>?
    private var connections = 0

    init(invite: RoomInvite, localMember: RoomMember) {
        self.invite = invite
        self.localMember = localMember
    }

    static func isAdvertising(_ invite: RoomInvite, within timeout: Duration) async -> Bool {
        let match = invite.txtMatch
        let endpoint = try? await withTimeout(timeout) {
            try await findHost(key: match.key, value: match.value, onDenied: {})
        }
        return endpoint != nil
    }

    func start() {
        guard task == nil else { return }
        task = Task {
            while !Task.isCancelled {
                await connectOnce()
                onConnectedChange(false)
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    func send(_ intent: GameIntent) {
        outbox?.yield(.game(intent))
    }

    func updateProfile(_ member: RoomMember) {
        localMember = member
        outbox?.yield(.updateProfile(member))
    }

    private func connectOnce() async {
        let match = invite.txtMatch
        let onDenied: @MainActor () -> Void = { [weak self] in self?.onPermissionDenied() }
        guard let endpoint = try? await withTimeout(.seconds(5), {
            try await findHost(key: match.key, value: match.value, onDenied: onDenied)
        }) else { return }

        let connection = NetworkConnection(to: endpoint, using: .reliable(ClientMessage.self, ServerMessage.self))
        let (outbox, continuation) = AsyncStream.makeStream(of: ClientMessage.self)
        self.outbox = continuation
        connections += 1
        let generation = connections
        let liveness = Liveness()
        let sender = Task {
            for await message in outbox {
                do { try await connection.send(message) } catch { liveness.isClosed = true; return }
            }
        }
        let receiver = Task {
            do {
                for try await message in connection.messages {
                    liveness.lastHeard = Date()
                    onConnectedChange(true)
                    receive(message.content)
                }
            } catch {}
            liveness.isClosed = true
        }

        continuation.yield(.hello(localMember))
        await liveness.watch { continuation.yield(.ping) }
        receiver.cancel()
        sender.cancel()
        continuation.finish()
        if connections == generation { self.outbox = nil }
    }

    private func receive(_ message: ServerMessage) {
        switch message {
        case .snapshot(let snapshot):
            onSnapshot(snapshot)
        case .roomFull:
            onRoomFull()
            stop()
        }
    }
}

@available(iOS 26.0, *)
private func findHost(key: String, value: String, onDenied: @escaping @MainActor () -> Void) async throws -> Bonjour.Endpoint {
    try await NetworkBrowser(for: .bonjour(RoomWire.service, includeTxtRecord: true), using: RoomWire.browseParameters)
        .onStateUpdate { _, state in
            switch state {
            case .waiting(let error), .failed(let error):
                if RoomWire.isPermissionDenied(error) { onDenied() }
            default:
                break
            }
        }
        .run { endpoints in
            endpoints.first { $0.txtRecord[key] == value }.map { .finish($0) } ?? .continue
        }
}

@MainActor
private final class Liveness {
    var lastHeard = Date()
    var isClosed = false

    func watch(beat: () -> Void) async {
        var nextBeat = Date.distantPast
        while !isClosed, !Task.isCancelled, Date().timeIntervalSince(lastHeard) < RoomWire.silenceLimit {
            if Date() >= nextBeat {
                beat()
                nextBeat = Date() + 1
            }
            try? await Task.sleep(for: .milliseconds(250))
        }
    }
}

private func withTimeout<T: Sendable>(_ duration: Duration, _ operation: @escaping @Sendable () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup { group in
        group.addTask { try await operation() }
        group.addTask {
            try await Task.sleep(for: duration)
            throw CancellationError()
        }
        defer { group.cancelAll() }
        guard let result = try await group.next() else { throw CancellationError() }
        return result
    }
}
