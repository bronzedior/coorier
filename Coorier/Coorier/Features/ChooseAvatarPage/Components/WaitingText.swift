//
//  WaitingText.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 24/10/26.
//

import SwiftUI

struct WaitingText: View {
    @State private var dotCount = 1

    private let dotInterval: TimeInterval = 0.5

    var body: some View {
        Text("Waiting\nfor seating" + String(repeating: ".", count: dotCount))
            .textCase(.uppercase)
            .font(.custom("Relaxe-Regular", size: 48))
            .foregroundStyle(.boneWhite100)
            .shadow(color: .black.opacity(0.74), radius: 0, x: 0, y: 3)
            .multilineTextAlignment(.center)
            .onAppear {
                startDotCycle()
            }
    }

    private func startDotCycle() {
        Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(dotInterval))
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    dotCount = dotCount % 3 + 1
                }
            }
        }
    }
}

#Preview {
    WaitingText()
        .padding()
        .background(Color.black)
}
