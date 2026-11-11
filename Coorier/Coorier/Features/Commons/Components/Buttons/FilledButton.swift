//
//  FilledButton.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 23/10/26.
//

import SwiftUI

struct FilledButton: View {
    enum Size {
        case large
        case medium
        case small
        case compact

        var font: Font {
            switch self {
            case .large: .custom("Relaxe-Regular", size: 72)
            case .medium: .custom("Relaxe-Regular", size: 48)
            case .small: .custom("Schoolbell-Regular", size: 24)
            case .compact: .custom("Relaxe-Regular", size: 36)
            }
        }

        var isUppercased: Bool {
            self == .large || self == .medium
        }

        var cornerRadius: CGFloat {
            self == .compact ? 25.2 : 30
        }

        var horizontalPadding: CGFloat {
            self == .compact ? 24 : 40
        }

        var verticalPadding: CGFloat {
            self == .compact ? 12 : 24
        }

        var minHeight: CGFloat? {
            self == .compact ? 66 : nil
        }
    }

    enum State {
        case active
        case disabled
    }

    let title: String
    let state: State
    let size: Size
    let color: Color
    let pressedColor: Color
    let fullWidth: Bool
    let action: () -> Void

    init(
        _ title: String,
        state: State = .active,
        size: Size = .large,
        color: Color = .success500,
        pressedColor: Color = .success700,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.state = state
        self.size = size
        self.color = color
        self.pressedColor = pressedColor
        self.fullWidth = fullWidth
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .textCase(size.isUppercased ? .uppercase : nil)
                .font(size.font)
                .foregroundStyle(.white)
                .frame(maxWidth: fullWidth ? .infinity : nil)
        }
        .buttonStyle(FilledButtonStyle(state: state, size: size, color: color, pressedColor: pressedColor))
        .disabled(state == .disabled)
    }
}

#Preview {
    VStack(spacing: 48) {
        FilledButton("Start", state: .active, size: .large) {}
        FilledButton("Join Friends", state: .active, size: .medium) {}
        FilledButton("Cancel", state: .active, size: .small) {}
        FilledButton("Ready for work", state: .active, size: .compact) {}
        FilledButton("Start", state: .disabled, size: .large) {}
    }
    .padding(24)
}
