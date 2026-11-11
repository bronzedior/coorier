//
//  GameMetrics.swift
//  Coorier
//

import CoreGraphics

struct GameMetrics {
    let size: CGSize
    let safeTop: CGFloat

    var scale: CGFloat { size.width / TableLayout.designWidth }
    var tableTop: CGFloat { TableLayout.tableTop * scale }
    var tableScreenHeight: CGFloat { max(size.height - tableTop, 0) }
    var tableScale: CGFloat { min(scale, tableScreenHeight / TableLayout.tableHeight) }
    var tableDesignHeight: CGFloat { tableScreenHeight / tableScale }

    func screen(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x * scale, y: tableTop + point.y * tableScale)
    }

    func screen(_ size: CGSize) -> CGSize {
        CGSize(width: size.width * scale, height: size.height * tableScale)
    }

    func design(_ size: CGSize) -> CGSize {
        CGSize(width: size.width / scale, height: size.height / tableScale)
    }

    func frame(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x * scale, y: point.y * scale)
    }

    func fromBottom(_ designDistance: CGFloat) -> CGFloat {
        size.height - designDistance * scale
    }
}

extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
