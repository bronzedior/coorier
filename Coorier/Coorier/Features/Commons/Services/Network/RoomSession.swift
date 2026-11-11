//
//  RoomSession.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 26/10/26.
//

import Foundation
import Observation

@MainActor @Observable
final class RoomSession {
    enum Role { case none, host, joiner }
    enum Status: Equatable { case idle, searching, connected, roomFull, permissionDenied, unsupported }
    
    private(set) var role: Role = .none
    private(set) var status: Status = .idle
    private(set) var snapshot: RoomSnapshot?
    private(set) var localMember = RoomMember(id: UUID().uuidString, name: "", photo: "")
    
    @ObservationIgnored private var host: AnyObject?
    @ObservationIgnored private var joiner: AnyObject?
    
    @available(iOS 26.0, *)
    private var roomHost: RoomHost? { host as? RoomHost }
    
    @available(iOS 26.0, *)
    private var roomJoiner: RoomJoiner? { joiner as? RoomJoiner }
    
    var isSupported: Bool {
        if #available(iOS 26.0, *) { true } else { false }
    }
    
    var members: [RoomMember] { snapshot?.members ?? [] }
    var hostID: MemberID? { snapshot?.hostID }
    var phase: RoomPhase { snapshot?.phase ?? .lobby }
    var game: GameState? { snapshot?.game }
    var isHost: Bool { role == .host }
    
    func host(seal: RoomSeal, code: RoomCode) {
        leave()
        guard #available(iOS 26.0, *) else {
            status = .unsupported
            return
        }
        let host = RoomHost(hostMember: localMember, seal: seal, code: code)
        host.onChange = { [weak self] in self?.snapshot = $0 }
        host.onPermissionDenied = { [weak self] in self?.setStatus(.permissionDenied) }
        self.host = host
        role = .host
        status = .connected
        host.start()
    }
    
    func join(_ invite: RoomInvite) {
        leave()
        guard #available(iOS 26.0, *) else {
            status = .unsupported
            return
        }
        let joiner = RoomJoiner(invite: invite, localMember: localMember)
        joiner.onSnapshot = { [weak self] snapshot in
            guard self?.snapshot != snapshot else { return }
            self?.snapshot = snapshot
        }
        joiner.onConnectedChange = { [weak self] connected in
            guard self?.status != .roomFull else { return }
            self?.setStatus(connected ? .connected : .searching)
        }
        joiner.onRoomFull = { [weak self] in self?.setStatus(.roomFull) }
        joiner.onPermissionDenied = { [weak self] in self?.setStatus(.permissionDenied) }
        self.joiner = joiner
        role = .joiner
        status = .searching
        joiner.start()
    }
    
    func leave() {
        if #available(iOS 26.0, *) {
            roomHost?.stop()
            roomJoiner?.stop()
        }
        host = nil
        joiner = nil
        role = .none
        status = .idle
        snapshot = nil
        localMember.name = ""
        localMember.photo = ""
    }
    
    func updateProfile(name: String, photo: String) {
        localMember.name = name
        localMember.photo = photo
        guard #available(iOS 26.0, *) else { return }
        roomHost?.updateProfile(localMember)
        roomJoiner?.updateProfile(localMember)
    }
    
    func swapSeats(_ first: MemberID, _ second: MemberID) {
        guard #available(iOS 26.0, *) else { return }
        roomHost?.swapSeats(first, second)
    }
    
    func startSeating() {
        guard #available(iOS 26.0, *) else { return }
        roomHost?.setPhase(.seating)
    }

    func startGame() {
        guard #available(iOS 26.0, *) else { return }
        roomHost?.startGame()
    }

    func send(_ intent: GameIntent) {
        guard #available(iOS 26.0, *) else { return }
        roomHost?.apply(intent, by: localMember.id)
        roomJoiner?.send(intent)
    }

    private func setStatus(_ new: Status) {
        if status != new { status = new }
    }
}
