//
//  StampArtwork.swift
//  Coorier
//

import SwiftUI

struct StampArtwork: Shape {
    let shape: StampShape

    private enum Ring {
        static let outerWidth: CGFloat = 1.3045
        static let outerInset: CGFloat = 0.652
        static let innerWidth: CGFloat = 0.868
        static let innerInset: CGFloat = 3.273
        static let outerRadius: CGFloat = 1.02
        static let innerRadius: CGFloat = 0.59
    }

    func path(in rect: CGRect) -> Path {
        let design = shape.designSize
        let scale = rect.width / design.width
        var path = Path()
        path.addPath(ring(inset: Ring.outerInset, width: Ring.outerWidth, radius: Ring.outerRadius))
        path.addPath(ring(inset: Ring.innerInset, width: Ring.innerWidth, radius: Ring.innerRadius))
        path.addPath(lettering())
        let transform = CGAffineTransform(translationX: rect.minX, y: rect.minY).scaledBy(x: scale, y: scale)
        return path.applying(transform)
    }

    private func ring(inset: CGFloat, width: CGFloat, radius: CGFloat) -> Path {
        let size = shape.designSize
        let box = CGRect(origin: .zero, size: size).insetBy(dx: inset, dy: inset)
        let outline: Path
        if let corners = shape.corners {
            outline = polygon(StampGeometry.inset(corners, by: inset))
        } else {
            switch shape {
            case .oval, .circle: outline = Path(ellipseIn: box)
            default: outline = Path(roundedRect: box, cornerRadius: radius)
            }
        }
        return outline.strokedPath(StrokeStyle(lineWidth: width, lineJoin: .round))
    }

    private func polygon(_ points: [CGPoint]) -> Path {
        var path = Path()
        path.addLines(points)
        path.closeSubpath()
        return path
    }

    private func lettering() -> Path {
        let size = shape.designSize
        if shape == .star {
            return StampSVGPath.path(from: StampStarLettering.paths, origin: .zero)
        }

        let placement = Self.placement(for: shape, in: size)
        let wordSize = StampLettering.wordSize
        let gap = Self.dotsGap * placement.scale
        let dotsSize = StampLettering.dotsSize
        let blockHeight = (wordSize.height + dotsSize.height) * placement.scale + gap
        let top = placement.center.y - blockHeight / 2
        let left = placement.center.x - wordSize.width * placement.scale / 2
        let wordHeight = wordSize.height * placement.scale
        let dotsHeight = dotsSize.height * placement.scale
        let dotsLeft = left + (StampLettering.dotsOrigin.x - StampLettering.wordOrigin.x) * placement.scale

        let wordTop = placement.dotsAbove ? top + dotsHeight + gap : top
        let dotsTop = placement.dotsAbove ? top : top + wordHeight + gap
        let scaling = CGAffineTransform(scaleX: placement.scale, y: placement.scale)

        var path = Path()
        let word = StampSVGPath.path(from: StampLettering.wordPaths, origin: StampLettering.wordOrigin)
        let dots = StampSVGPath.path(from: StampLettering.dotsPaths, origin: StampLettering.dotsOrigin)
        path.addPath(word.applying(scaling.concatenating(CGAffineTransform(translationX: left, y: wordTop))))
        path.addPath(dots.applying(scaling.concatenating(CGAffineTransform(translationX: dotsLeft, y: dotsTop))))
        return path
    }

    private static let dotsGap = StampLettering.dotsOrigin.y - StampLettering.wordOrigin.y - StampLettering.wordSize.height

    private struct Placement {
        let center: CGPoint
        let scale: CGFloat
        var dotsAbove = false
    }

    private static func placement(for shape: StampShape, in size: CGSize) -> Placement {
        let middle = CGPoint(x: size.width / 2, y: size.height / 2)
        switch shape {
        case .square: return Placement(center: CGPoint(x: middle.x, y: middle.y + 0.7), scale: 1)
        case .diamond: return Placement(center: CGPoint(x: middle.x, y: 20.77), scale: 0.8)
        case .triangle: return Placement(center: CGPoint(x: middle.x, y: 25.2), scale: 0.8, dotsAbove: true)
        default: return Placement(center: CGPoint(x: middle.x, y: middle.y - 0.3), scale: 1)
        }
    }
}
