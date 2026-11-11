//
//  Arrows.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 26/10/26.
//

import SwiftUI

enum ArrowDirection {
    case left
    case right

    var flipped: Bool { self == .left }
}

struct ArrowShape: Shape {
    private let shaftHeightFraction: CGFloat = 0.34

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let shaftHeight = rect.height * shaftHeightFraction
        let shaftTop = rect.midY - shaftHeight / 2
        let shaftWidth = rect.width * 0.55

        path.addRect(CGRect(x: rect.minX, y: shaftTop, width: shaftWidth, height: shaftHeight))
        path.move(to: CGPoint(x: rect.minX + shaftWidth, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX + shaftWidth, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct InteractableArrow: View {
    let direction: ArrowDirection
    var action: () -> Void = {}

    private let length: CGFloat = 64
    private let height: CGFloat = 40

    var body: some View {
        Button(action: action) {
            ArrowShape()
                .fill(Color(.success500))
                .frame(width: length, height: height)
                .scaleEffect(x: direction.flipped ? -1 : 1)
        }
        .accessibilityLabel(direction == .left ? "Submit left" : "Submit right")
    }
}

struct DirectionArrow: View {
    let direction: ArrowDirection

    private let length: CGFloat = 64
    private let height: CGFloat = 40

    var body: some View {
        ArrowShape()
            .fill(Color(.boneWhite100))
            .frame(width: length, height: height)
            .scaleEffect(x: direction.flipped ? -1 : 1)
            .accessibilityLabel(direction == .left ? "Points left" : "Points right")
    }
}

#Preview {
    VStack(spacing: 40) {
        HStack(spacing: 40) {
            InteractableArrow(direction: .left)
            InteractableArrow(direction: .right)
        }
        HStack(spacing: 40) {
            DirectionArrow(direction: .left)
            DirectionArrow(direction: .right)
        }
    }
    .padding(40)
    .background(Color(.bearBrown700))
}
