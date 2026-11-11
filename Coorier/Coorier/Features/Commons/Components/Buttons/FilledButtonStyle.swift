//
//  FilledButtonStyle.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 23/10/26.
//

import SwiftUI

struct FilledButtonStyle: ButtonStyle {
    let state: FilledButton.State
    let size: FilledButton.Size
    var color: Color = .success500
    var pressedColor: Color = .success700

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
        return configuration.label
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .frame(minHeight: size.minHeight)
            .background(fillColor(isPressed: configuration.isPressed))
            .clipShape(shape)
            .overlay(shape.stroke(.boneWhite100.opacity(0.2), lineWidth: 4))
            .shadow(color: .black.opacity(0.2), radius: 0, x: 8, y: 8)
    }

    private func fillColor(isPressed: Bool) -> Color {
        switch state {
        case .disabled: .neutral300
        case .active: isPressed ? pressedColor : color
        }
    }
}
