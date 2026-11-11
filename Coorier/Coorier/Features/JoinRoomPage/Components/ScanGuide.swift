//
//  ScanGuide.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 23/10/26.
//

import SwiftUI

struct ScanGuide: View {
    static let lineWidth: CGFloat = 7

    var isLocked = false

    var body: some View {
        Circle()
            .stroke(
                .white,
                style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .butt, dash: isLocked ? [] : [24, 14])
            )
            .shadow(color: .black.opacity(0.3), radius: 2)
            .animation(.easeOut(duration: 0.2), value: isLocked)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        ScanGuide()
        ScanGuide(isLocked: true)
    }
    .padding()
    .background(Color.gray)
}
