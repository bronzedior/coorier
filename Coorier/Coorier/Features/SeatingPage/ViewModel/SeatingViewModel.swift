//
//  SeatingViewModel.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 25/10/26.
//

import SwiftUI

@Observable
final class SeatingViewModel {
    private(set) var players: [Player] = []
    private(set) var hostPlayerID: Int?

    private(set) var draggingPlayer: Player?
    private(set) var hoveredPlayer: Player?
    private(set) var dragOffset: CGSize = .zero
    private(set) var dragAnchor: CGRect = .zero
    private(set) var holdLift = false
    private(set) var displacedFlight: DisplacedFlight?
    private(set) var displacedOffset: CGSize = .zero
    private(set) var showDragPlaceholder = false
    private(set) var guideStep: SeatingGuideStep?
    var cellFrames: [Int: CGRect] = [:]

    let dragAngle: Double = 4
    let dragShadowRadius: CGFloat = 32
    let dragShadowOpacity: Double = 0.5
    let dragLiftY: CGFloat = 4
    let dragSettleDuration: TimeInterval = 0.3

    private let testNames = [
        "Andy", "Bella", "Citra", "Dodi", "Eka", "Fajar",
        "Gita", "Hana", "Indra", "Joko", "Kira", "Luna"
    ]

    private var settleTask: Task<Void, Never>?

    @ObservationIgnored var onSwap: (MemberID, MemberID) -> Void = { _, _ in }
    @ObservationIgnored private var seatIDs: [MemberID: Int] = [:]
    @ObservationIgnored private var pendingMembers: [RoomMember]?
    @ObservationIgnored private var pendingHostID: MemberID?

    init(playerCount: Int = SeatingModel.minPlayers) {
        seatPlayers(count: playerCount)
    }

    func playerAt(row: Int, column: Int) -> Player? {
        guard let columns = SeatingModel.arrangements[players.count] else { return nil }
        guard row >= 1, row <= columns.count else { return nil }
        guard let order = columns[row - 1].firstIndex(of: column) else { return nil }
        let index = columns.prefix(row - 1).reduce(0) { $0 + $1.count } + order
        return players.indices.contains(index) ? players[index] : nil
    }

    func swap(_ player: Player, with other: Player) {
        guard player.id != hostPlayerID, other.id != hostPlayerID else { return }
        guard let firstIndex = players.firstIndex(where: { $0.id == player.id }),
              let secondIndex = players.firstIndex(where: { $0.id == other.id }) else { return }
        players.swapAt(firstIndex, secondIndex)
    }

    func apply(_ members: [RoomMember], hostID: MemberID?) {
        guard SeatingModel.arrangements[members.count] != nil else { return }
        guard draggingPlayer == nil else {
            pendingMembers = members
            pendingHostID = hostID
            return
        }
        let members = hostID.map { SeatingModel.placingHost(members, hostID: $0) } ?? members
        let seated = members.map { member in
            Player(
                id: seatID(for: member.id),
                photo: member.photo.isEmpty ? SeatingModel.photos[0] : member.photo,
                name: member.name.isEmpty ? "Choosing..." : member.name
            )
        }
        if let hostID {
            hostPlayerID = seatID(for: hostID)
        }
        guard seated != players else { return }
        players = seated
    }

    private func seatID(for member: MemberID) -> Int {
        if let id = seatIDs[member] { return id }
        let id = seatIDs.count
        seatIDs[member] = id
        return id
    }

    private func memberID(of player: Player) -> MemberID? {
        seatIDs.first { $0.value == player.id }?.key
    }

    func seatPlayers(count: Int) {
        let clamped = min(max(count, SeatingModel.minPlayers), SeatingModel.maxPlayers)
        let photos = SeatingModel.photos.shuffled()
        let names = testNames.shuffled()
        var seated = (0..<clamped).map { index in
            Player(
                id: index,
                photo: photos[index % photos.count],
                name: names[index % names.count]
            )
        }
        hostPlayerID = seated.first?.id
        if let host = seated.first, let hostIndex = SeatingModel.hostIndex(count: clamped) {
            seated.removeFirst()
            seated.insert(host, at: hostIndex)
        }
        players = seated
    }

    func startDrag(player: Player, row: Int, column: Int) {
        guard player.id != hostPlayerID else { return }
        guideStep = nil
        dragAnchor = cellFrames[SeatingModel.cellKey(row: row, column: column)] ?? .zero
        draggingPlayer = player
        showDragPlaceholder = true
        withAnimation(.spring(duration: 0.25)) {
            holdLift = true
        }
    }

    func dragChanged(translation: CGSize, row: Int, column: Int) {
        if draggingPlayer == nil { return }
        dragOffset = translation
        hoveredPlayer = dropTarget(fromRow: row, column: column, translation: translation)
    }

    func endDrag(player: Player) {
        var targetFrame: CGRect?
        if let target = hoveredPlayer, target.id != player.id {
            swap(player, with: target)
            if let first = memberID(of: player), let second = memberID(of: target) {
                onSwap(first, second)
            }
            targetFrame = draggingPlayerCellFrame
            displacedFlight = DisplacedFlight(player: target, origin: targetFrame ?? dragAnchor)
            displacedOffset = .zero
        }
        withAnimation(.spring(duration: dragSettleDuration)) {
            holdLift = false
            hoveredPlayer = nil
            if let target = targetFrame {
                dragOffset = CGSize(
                    width: target.midX - dragAnchor.midX,
                    height: target.midY - dragAnchor.midY
                )
                displacedOffset = CGSize(
                    width: dragAnchor.midX - target.midX,
                    height: dragAnchor.midY - target.midY
                )
            } else {
                dragOffset = .zero
            }
        }
        settleTask?.cancel()
        settleTask = Task {
            try? await Task.sleep(for: .seconds(dragSettleDuration + 0.1))
            guard !Task.isCancelled, draggingPlayer?.id == player.id else { return }
            draggingPlayer = nil
            displacedFlight = nil
            withAnimation(.easeOut(duration: 0.2)) {
                showDragPlaceholder = false
            }
            dragOffset = .zero
            displacedOffset = .zero
            if let pending = pendingMembers {
                pendingMembers = nil
                let hostID = pendingHostID
                pendingHostID = nil
                apply(pending, hostID: hostID)
            }
        }
    }

    var draggingPlayerCellFrame: CGRect? {
        for (key, frame) in cellFrames {
            let cell = SeatingModel.keyRowColumn(key)
            if playerAt(row: cell.row, column: cell.column)?.id == draggingPlayer?.id {
                return frame
            }
        }
        return nil
    }

    func isDraggingCell(row: Int, column: Int) -> Bool {
        playerAt(row: row, column: column)?.id == draggingPlayer?.id
    }

    func beginGuide() {
        guard guideStep == nil, !players.isEmpty else { return }
        guideStep = .one
    }

    func advanceGuide() {
        switch guideStep {
        case .one: guideStep = .two
        case .two: guideStep = .three
        default: guideStep = nil
        }
    }

    func backGuide() {
        if guideStep == .two { guideStep = .one }
    }

    func endGuide() {
        guideStep = nil
    }

    var guideTargetPlayer: Player? {
        switch guideStep {
        case .one:
            return players.first { $0.id == hostPlayerID }
        case .two, .three:
            return leftNeighborOfHost()
        default:
            return nil
        }
    }

    func guideTargetFrame() -> CGRect? {
        guard let target = guideTargetPlayer else { return nil }
        return cellFor(player: target)?.frame
    }

    private func leftNeighborOfHost() -> Player? {
        guard let hostPlayerID,
              let hostIndex = players.firstIndex(where: { $0.id == hostPlayerID }) else { return nil }
        let ring = SeatingModel.ring(count: players.count)
        guard let position = ring.firstIndex(of: hostIndex), !ring.isEmpty else { return nil }
        return players[ring[(position + 1) % ring.count]]
    }

    private func cellFor(player: Player) -> SeatCell? {
        for (key, frame) in cellFrames {
            let cell = SeatingModel.keyRowColumn(key)
            if playerAt(row: cell.row, column: cell.column)?.id == player.id {
                return SeatCell(row: cell.row, column: cell.column, frame: frame)
            }
        }
        return nil
    }

    private func dropTarget(fromRow row: Int, column: Int, translation: CGSize) -> Player? {
        guard let sourceFrame = cellFrames[SeatingModel.cellKey(row: row, column: column)] else { return nil }
        let center = CGPoint(
            x: sourceFrame.midX + translation.width,
            y: sourceFrame.midY + translation.height
        )
        for (key, frame) in cellFrames where frame.contains(center) {
            let cell = SeatingModel.keyRowColumn(key)
            guard cell != (row, column) else { return nil }
            guard let target = playerAt(row: cell.row, column: cell.column), target.id != hostPlayerID else { return nil }
            return target
        }
        return nil
    }
}

private struct SeatCell {
    let row: Int
    let column: Int
    let frame: CGRect
}
