//
//  SpinningFire.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 24/10/26.
//

import SwiftUI

struct SpinningFire: View {
    @State private var rotation: Double = 0

    private let size: CGFloat = 750
    private let turnDuration: Double = 9

    var body: some View {
        Color.clear
            .overlay {
                Image(.fire)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(rotation))
            }
            .onAppear {
                withAnimation(.linear(duration: turnDuration).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

#Preview {
    SpinningFire()
        .background(Color.black)
}
