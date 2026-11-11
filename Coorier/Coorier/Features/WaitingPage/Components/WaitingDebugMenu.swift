//
//  WaitingDebugMenu.swift
//  Coorier
//

#if DEBUG
import SwiftUI

struct WaitingDebugMenu: View {
    let onForcePlay: () -> Void

    var body: some View {
        Menu {
            Button("Force play", systemImage: "play.fill", action: onForcePlay)
        } label: {
            Image(systemName: "ladybug.fill")
                .font(.footnote.bold())
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.black.opacity(0.55), in: .circle)
        }
        .accessibilityLabel("Debug menu")
    }
}
#endif
