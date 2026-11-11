//
//  ArrowButton.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 24/10/26.
//

import SwiftUI

struct ArrowButton: View {
    enum Direction {
        case left
        case right

        var rotation: Angle {
            self == .left ? .degrees(-90) : .degrees(90)
        }
    }

    let direction: Direction
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            TriangleShape()
                .fill(.deepTeal)
                .frame(width: 48, height: 48)
                .rotationEffect(direction.rotation)
        }
        .shadow(color: .black.opacity(0.2), radius: 0, x: 8, y: 8)
        .accessibilityLabel(direction == .left ? "Previous" : "Next")
    }
}

#Preview {
    HStack(spacing: 48) {
        ArrowButton(direction: .left) {}
        ArrowButton(direction: .right) {}
    }
    .padding()
}
