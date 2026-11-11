//
//  EndView.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 27/10/26.
//

import SwiftUI

struct EndView: View {
    var onMainMenu: () -> Void

    var body: some View {
        ZStack {
            Image(.end)
                .resizable()
                .ignoresSafeArea()
            Color.black
                .opacity(0.65)
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                Text("Good Luck\nOn Your Next Shift")
                    .font(.relaxe(48))
                    .foregroundStyle(.boneWhite)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)

                FilledButton(
                    "Main Menu",
                    size: .compact,
                    color: .warning500,
                    pressedColor: .warning700,
                    fullWidth: true
                ) {
                    onMainMenu()
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    EndView(onMainMenu: {})
}
