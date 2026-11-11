//
//  StrokedButton.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 24/10/26.
//

import SwiftUI

struct StrokedButton: View {
    let title: String
    let state: FilledButton.State
    let size: FilledButton.Size
    let action: () -> Void

    init(
        _ title: String,
        state: FilledButton.State = .active,
        size: FilledButton.Size = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.state = state
        self.size = size
        self.action = action
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: StrokedButtonStyle.cornerRadius(for: size), style: .continuous)
        return Button(action: action) {
            Text(title)
                .textCase(size.isUppercased ? .uppercase : nil)
                .font(size.font)
                .foregroundStyle(.destructive700)
        }
        .buttonStyle(StrokedButtonStyle(state: state, size: size))
        .clipShape(shape)
        .disabled(state == .disabled)
    }
}

struct StrokedButtonStyle: ButtonStyle {
    let state: FilledButton.State
    let size: FilledButton.Size

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return configuration.label
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(minHeight: size.minHeight)
            .overlay(shape.stroke(.destructive700, lineWidth: 10))
            .opacity(state == .disabled ? 0.5 : 1.0)
    }

    static func cornerRadius(for size: FilledButton.Size) -> CGFloat {
        size == .medium ? 6 : size.cornerRadius
    }

    private var cornerRadius: CGFloat {
        Self.cornerRadius(for: size)
    }

    private var horizontalPadding: CGFloat {
        size == .medium ? 16 : size.horizontalPadding
    }

    private var verticalPadding: CGFloat {
        size == .medium ? 8 : size.verticalPadding
    }
}

#Preview {
    VStack(spacing: 48) {
        StrokedButton("Start", size: .large) {}
        StrokedButton("Join Friends", size: .medium) {}
        StrokedButton("Cancel", size: .small) {}
        StrokedButton("Ready for work", size: .compact) {}
        StrokedButton("Start", state: .disabled, size: .medium) {}
    }
    .padding(24)
}
