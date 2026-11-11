//
//  TriangleShape.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 24/10/26.
//

import SwiftUI

struct TriangleShape: Shape {
    var cornerRadius: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        let vertices = [
            CGPoint(x: rect.midX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.maxY)
        ]
        let radius = min(cornerRadius, rect.width / 4, rect.height / 4)

        var path = Path()
        for index in 0..<vertices.count {
            let vertex = vertices[index]
            let previous = vertices[(index + vertices.count - 1) % vertices.count]
            let next = vertices[(index + 1) % vertices.count]

            let toPrevious = unit(from: vertex, to: previous) * radius
            let toNext = unit(from: vertex, to: next) * radius

            let entry = vertex + toPrevious
            let exit = vertex + toNext

            if index == 0 {
                path.move(to: entry)
            } else {
                path.addLine(to: entry)
            }
            path.addQuadCurve(to: exit, control: vertex)
        }
        path.closeSubpath()
        return path
    }

    private func unit(from origin: CGPoint, to target: CGPoint) -> CGPoint {
        let deltaX = target.x - origin.x
        let deltaY = target.y - origin.y
        let length = sqrt(deltaX * deltaX + deltaY * deltaY)
        guard length > 0 else { return .zero }
        return CGPoint(x: deltaX / length, y: deltaY / length)
    }
}

private func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

private func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}
