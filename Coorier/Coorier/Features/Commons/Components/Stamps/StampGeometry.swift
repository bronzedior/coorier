//
//  StampGeometry.swift
//  Coorier
//

import CoreGraphics

enum StampGeometry {
    static func inset(_ points: [CGPoint], by distance: CGFloat) -> [CGPoint] {
        let count = points.count
        guard count > 2 else { return points }
        let isCounterClockwise = signedArea(points) > 0

        let lines = (0 ..< count).map { index -> (point: CGPoint, direction: CGVector) in
            let start = points[index]
            let end = points[(index + 1) % count]
            let length = hypot(end.x - start.x, end.y - start.y)
            let direction = CGVector(dx: (end.x - start.x) / length, dy: (end.y - start.y) / length)
            let normal = isCounterClockwise ? CGVector(dx: -direction.dy, dy: direction.dx) : CGVector(dx: direction.dy, dy: -direction.dx)
            return (CGPoint(x: start.x + normal.dx * distance, y: start.y + normal.dy * distance), direction)
        }

        return (0 ..< count).map { index in
            intersection(of: lines[(index + count - 1) % count], and: lines[index]) ?? points[index]
        }
    }

    private static func signedArea(_ points: [CGPoint]) -> CGFloat {
        var sum: CGFloat = 0
        for index in points.indices {
            let next = points[(index + 1) % points.count]
            sum += points[index].x * next.y - next.x * points[index].y
        }
        return sum / 2
    }

    private static func intersection(
        of first: (point: CGPoint, direction: CGVector),
        and second: (point: CGPoint, direction: CGVector)
    ) -> CGPoint? {
        let cross = first.direction.dx * second.direction.dy - first.direction.dy * second.direction.dx
        guard abs(cross) > 0.0001 else { return nil }
        let delta = CGVector(dx: second.point.x - first.point.x, dy: second.point.y - first.point.y)
        let along = (delta.dx * second.direction.dy - delta.dy * second.direction.dx) / cross
        return CGPoint(x: first.point.x + first.direction.dx * along, y: first.point.y + first.direction.dy * along)
    }
}
