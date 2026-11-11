//
//  GlowPulse.swift
//  Coorier
//

import SwiftUI

struct GlowPulse: ViewModifier {
    let isOn: Bool

    @State private var isBright = false

    func body(content: Content) -> some View {
        content
            .shadow(color: Color(.boneWhite400).opacity(isOn && isBright ? 0.95 : 0), radius: 10)
            .shadow(color: Color(.boneWhite400).opacity(isOn && isBright ? 0.6 : 0), radius: 4)
            .opacity(isOn ? (isBright ? 1 : 0.45) : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    isBright = true
                }
            }
    }
}
