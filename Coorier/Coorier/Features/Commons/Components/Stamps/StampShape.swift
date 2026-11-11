//
//  StampShape.swift
//  Coorier
//

import CoreGraphics

enum StampShape: CaseIterable {
    case oval
    case circle
    case hexagon
    case square
    case star
    case rectangle
    case triangle
    case diamond

    var designSize: CGSize {
        switch self {
        case .oval: CGSize(width: 48.165, height: 28.855)
        case .circle: CGSize(width: 34.142, height: 34.142)
        case .hexagon: CGSize(width: 37.974, height: 33.927)
        case .square: CGSize(width: 33.614, height: 33.614)
        case .star: CGSize(width: 38.521, height: 37.008)
        case .rectangle: CGSize(width: 50.237, height: 28.061)
        case .triangle: CGSize(width: 37.590, height: 32.888)
        case .diamond: CGSize(width: 32, height: 40)
        }
    }

    var aspectRatio: CGFloat {
        designSize.width / designSize.height
    }

    var accessibilityName: String {
        switch self {
        case .oval: "Oval stamp"
        case .circle: "Circle stamp"
        case .hexagon: "Hexagon stamp"
        case .square: "Square stamp"
        case .star: "Star stamp"
        case .rectangle: "Rectangle stamp"
        case .triangle: "Triangle stamp"
        case .diamond: "Diamond stamp"
        }
    }

    var corners: [CGPoint]? {
        let size = designSize
        switch self {
        case .hexagon:
            return [
                CGPoint(x: size.width * 0.25, y: 0), CGPoint(x: size.width * 0.75, y: 0),
                CGPoint(x: size.width, y: size.height / 2), CGPoint(x: size.width * 0.75, y: size.height),
                CGPoint(x: size.width * 0.25, y: size.height), CGPoint(x: 0, y: size.height / 2)
            ]
        case .triangle:
            return [CGPoint(x: size.width / 2, y: 0), CGPoint(x: size.width, y: size.height), CGPoint(x: 0, y: size.height)]
        case .diamond:
            return [
                CGPoint(x: size.width / 2, y: 0), CGPoint(x: size.width, y: size.height / 2),
                CGPoint(x: size.width / 2, y: size.height), CGPoint(x: 0, y: size.height / 2)
            ]
        case .star:
            return starCorners()
        default:
            return nil
        }
    }

    private func starCorners() -> [CGPoint] {
        let innerRatio: CGFloat = 0.5
        let raw = (0 ..< 10).map { index -> CGPoint in
            let radius: CGFloat = index.isMultiple(of: 2) ? 1 : innerRatio
            let angle = -CGFloat.pi / 2 + CGFloat(index) * .pi / 5
            return CGPoint(x: radius * cos(angle), y: radius * sin(angle))
        }
        let minX = raw.map(\.x).min() ?? 0
        let maxX = raw.map(\.x).max() ?? 1
        let minY = raw.map(\.y).min() ?? 0
        let maxY = raw.map(\.y).max() ?? 1
        let size = designSize
        return raw.map { point in
            CGPoint(
                x: (point.x - minX) / (maxX - minX) * size.width,
                y: (point.y - minY) / (maxY - minY) * size.height
            )
        }
    }
}
