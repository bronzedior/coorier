//
//  GameRoomViewModel.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 26/10/26.
//

import SwiftUI

@Observable
final class GameRoomViewModel {
    let service: any GameService

    private(set) var spots: [Int: TableSpot] = [:]
    private(set) var motions: [Int: ItemMotion] = [:]
    private(set) var draggingID: Int?
    private(set) var dragTranslation: CGSize = .zero

    private(set) var combining: Combining?
    private(set) var sealProgress: [Int: CGFloat] = [:]

    private(set) var requestLine = BirdLines.requests[0]
    private(set) var isWrongLine = false
    private(set) var isReceiving = false
    private(set) var wrongMark: WrongMarkPlacement?

    private(set) var sparkleTrigger = 0
    private(set) var sparkleCenter = TableLayout.sealedSpot.center
    private(set) var passFeedback = 0
    private(set) var successFeedback = 0
    private(set) var errorFeedback = 0

    var tableHeight: CGFloat = TableLayout.tableHeight

    private(set) var isIdle = false
    var forceIdleHint = false
    static let idleDelay: TimeInterval = 120
    @ObservationIgnored private var lastActivity = Date()
    @ObservationIgnored private var idleTask: Task<Void, Never>?

    @ObservationIgnored private var lineTask: Task<Void, Never>?
    @ObservationIgnored private var receiveTask: Task<Void, Never>?

    struct Combining: Equatable {
        let letterID: Int
        let mailID: Int
        var insertProgress: CGFloat = 0
    }

    struct WrongMarkPlacement: Equatable {
        let center: CGPoint
        let id: Int
    }

    init(service: any GameService) {
        self.service = service
        requestLine = BirdLines.requests.randomElement() ?? requestLine
        watchForIdle()
    }

    var state: GameState? { service.state }
    var myID: MemberID { service.myID }
    var bird: Bird? { state?.birds[myID] }
    var title: String { GameState.title }
    var sent: Int { state?.sentCount(for: myID) ?? 0 }
    var total: Int { GameState.mailsPerPlayer }
    var isFinished: Bool { state?.isFinished ?? false }

    var myItems: [GameItem] {
        (state?.items(heldBy: myID) ?? []).sorted { $0.id < $1.id }
    }

    var myItemIDs: [Int] { myItems.map(\.id) }

    var hint: String? {
        let items = myItems
        guard bird != nil else { return nil }
        let canAssemble = items.contains { letter in
            letter.isLetter && items.contains { $0.isMail && $0.color == letter.color }
        }
        if canAssemble { return "put the letter on the envelope" }
        if sent >= total && !isFinished { return "All your mail is sent. Keep passing!" }
        return nil
    }

    var showsIdleHint: Bool { isIdle || forceIdleHint }

    func noteActivity() {
        lastActivity = Date()
        if isIdle { isIdle = false }
    }

    private func watchForIdle() {
        idleTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self else { return }
                let idle = Date().timeIntervalSince(self.lastActivity) >= Self.idleDelay
                if idle != self.isIdle { self.isIdle = idle }
            }
        }
    }

    func spot(for id: Int) -> TableSpot {
        spots[id] ?? TableLayout.mailSpots[0]
    }

    func motion(for id: Int) -> ItemMotion {
        motions[id] ?? ItemMotion()
    }

    func isReadyToSend(_ item: GameItem) -> Bool {
        guard item.isSealed else { return false }
        return item.color == bird?.request
    }

    func sealProgress(for item: GameItem) -> CGFloat {
        item.isSealed ? 1 : sealProgress[item.id] ?? 0
    }

    func syncTable() {
        let items = myItems
        let ids = Set(items.map(\.id))
        for id in spots.keys where !ids.contains(id) {
            spots[id] = nil
            motions[id] = nil
            sealProgress[id] = nil
        }
        for item in items where spots[item.id] == nil {
            spots[item.id] = item.isSealed && !isSealedSpotTaken
                ? TableLayout.sealedSpot
                : TableLayout.freeSpot(isMail: !item.isLetter, taken: Array(spots.values))
        }
    }

    func leave() {
        lineTask?.cancel()
        receiveTask?.cancel()
        idleTask?.cancel()
        service.leave()
    }

    func setMotion(_ id: Int, _ change: (inout ItemMotion) -> Void) {
        var motion = motions[id] ?? ItemMotion()
        change(&motion)
        motions[id] = motion
    }

    func setSpot(_ id: Int, _ spot: TableSpot) {
        spots[id] = spot
    }

    func moveToSealedSpotIfFree(_ id: Int) {
        guard !isSealedSpotTaken else { return }
        withAnimation(.spring(duration: 0.45)) { spots[id] = TableLayout.sealedSpot }
    }

    private var isSealedSpotTaken: Bool {
        spots.values.contains { $0.center == TableLayout.sealedSpot.center }
    }

    func setDragging(_ id: Int?, translation: CGSize = .zero) {
        draggingID = id
        dragTranslation = translation
    }

    func setCombining(_ value: Combining?) {
        combining = value
    }

    func setSeal(_ id: Int, _ progress: CGFloat) {
        sealProgress[id] = progress
    }

    func fireSparkles(at center: CGPoint) {
        sparkleCenter = center
        sparkleTrigger += 1
        successFeedback += 1
    }

    func firePass() {
        passFeedback += 1
    }

    func showWrong(at center: CGPoint) {
        errorFeedback += 1
        let placement = WrongMarkPlacement(center: center, id: errorFeedback)
        withAnimation(.spring(duration: 0.3, bounce: 0.5)) {
            wrongMark = placement
            isWrongLine = true
        }
        lineTask?.cancel()
        lineTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.1))
            withAnimation(.easeOut(duration: 0.25)) {
                if self?.wrongMark == placement { self?.wrongMark = nil }
            }
            try? await Task.sleep(for: .seconds(1.1))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.2)) { self?.isWrongLine = false }
        }
    }

    func showReceived() {
        successFeedback += 1
        withAnimation(.spring(duration: 0.35)) { isReceiving = true }
        receiveTask?.cancel()
        receiveTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.8))
            guard !Task.isCancelled else { return }
            withAnimation(.spring(duration: 0.35)) {
                self?.isReceiving = false
                self?.requestLine = BirdLines.requests.randomElement() ?? BirdLines.requests[0]
            }
        }
    }
}
