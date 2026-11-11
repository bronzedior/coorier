//
//  NameTakenNote.swift
//  Coorier
//

import SwiftUI

struct NameTakenNote: View {
    let isVisible: Bool

    var body: some View {
        Text("Can't be the same as another player")
            .font(.schoolbell(16))
            .foregroundStyle(Color(.destructive500))
            .fixedSize()
            .offset(y: 8)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: isVisible)
            .accessibilityHidden(!isVisible)
    }
}
