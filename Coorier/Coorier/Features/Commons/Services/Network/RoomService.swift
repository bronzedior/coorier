//
//  RoomService.swift
//  Coorier
//

enum JoinOutcome {
    case joined
    case rejected
}

protocol RoomService {
    func publish(seal: RoomSeal, code: RoomCode)
    func unpublish()
    func join(seal: RoomSeal, code: RoomCode?) -> JoinOutcome
    func roomExists(code: RoomCode) async -> Bool
}

final class MockRoomService: RoomService {
    static let shared = MockRoomService()

    private var hosted: (seal: RoomSeal, code: RoomCode)?

    func publish(seal: RoomSeal, code: RoomCode) {
        hosted = (seal, code)
    }

    func unpublish() {
        hosted = nil
    }

    func join(seal: RoomSeal, code: RoomCode?) -> JoinOutcome {
        guard let hosted else { return .joined }
        guard hosted.seal == seal else { return .rejected }
        if let code, code != hosted.code { return .rejected }
        return .joined
    }

    func roomExists(code: RoomCode) async -> Bool {
        guard let hosted else { return true }
        return hosted.code == code
    }
}

final class NetworkRoomService: RoomService {
    static let shared = NetworkRoomService()

    let session = RoomSession()

    private var published: (seal: RoomSeal, code: RoomCode)?
    private var invite: RoomInvite?

    var playerCount: Int { max(session.members.count, 1) }

    func publish(seal: RoomSeal, code: RoomCode) {
        if let published, published.seal == seal, published.code == code, session.isHost { return }
        invite = nil
        published = (seal, code)
        session.host(seal: seal, code: code)
    }

    func unpublish() {
        guard published != nil else { return }
        published = nil
        session.leave()
    }

    func join(seal: RoomSeal, code: RoomCode?) -> JoinOutcome {
        let invite: RoomInvite = code.map(RoomInvite.code) ?? .seal(seal)
        if self.invite == invite, session.role == .joiner { return .joined }
        published = nil
        self.invite = invite
        session.join(invite)
        return .joined
    }

    func leave() {
        published = nil
        invite = nil
        session.leave()
    }

    func roomExists(code: RoomCode) async -> Bool {
        guard #available(iOS 26.0, *) else { return false }
        return await RoomJoiner.isAdvertising(.code(code), within: .seconds(4))
    }
}
