//
//  TableLayout.swift
//  Coorier
//

import CoreGraphics

struct TableSpot: Equatable {
    var center: CGPoint
    var angle: Double = 0
}

struct ItemMotion: Equatable {
    var offset: CGSize = .zero
    var scale: CGFloat = 1
    var opacity: Double = 1
    var shakes: CGFloat = 0
}

enum TableLayout {
    static let designWidth: CGFloat = 402
    static let designHeight: CGFloat = 874
    static let tableTop: CGFloat = 349
    static let tableHeight: CGFloat = designHeight - tableTop

    static let sealedSpot = TableSpot(center: CGPoint(x: 190.5, y: 165))

    static let mailSpots: [TableSpot] = [
        TableSpot(center: CGPoint(x: 142.5, y: 141)),
        TableSpot(center: CGPoint(x: 268, y: 186), angle: -4),
        TableSpot(center: CGPoint(x: 150, y: 330), angle: 3),
        TableSpot(center: CGPoint(x: 272, y: 382), angle: -2)
    ]
    static let letterSpots: [TableSpot] = [
        TableSpot(center: CGPoint(x: 241, y: 278)),
        TableSpot(center: CGPoint(x: 128, y: 412), angle: 4),
        TableSpot(center: CGPoint(x: 292, y: 436), angle: -3),
        TableSpot(center: CGPoint(x: 205, y: 205), angle: 2)
    ]

    static let birdTarget = CGPoint(x: 92, y: -150)

    static func freeSpot(isMail: Bool, taken: [TableSpot]) -> TableSpot {
        let candidates = isMail ? mailSpots : letterSpots
        if let free = candidates.first(where: { candidate in !taken.contains { $0.center == candidate.center } }) {
            return free
        }
        let base = candidates[taken.count % candidates.count]
        let nudge = CGFloat(taken.count % 3) * 14
        return TableSpot(center: CGPoint(x: base.center.x + nudge, y: base.center.y + nudge), angle: base.angle)
    }

    static func clamp(_ point: CGPoint, height: CGFloat) -> CGPoint {
        CGPoint(x: min(max(point.x, 60), designWidth - 60), y: min(max(point.y, 60), max(height - 60, 60)))
    }
}
