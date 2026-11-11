//
//  BirdView.swift
//  Coorier
//

import SwiftUI

struct BirdView: View {
    let bird: Bird
    var isReceiving = false

    var body: some View {
        Image(isReceiving ? bird.receivedImage ?? bird.characterImage : bird.characterImage)
            .keyframeAnimator(initialValue: CGFloat(1), trigger: isReceiving) { content, scale in
                content.scaleEffect(scale, anchor: .bottom)
            } keyframes: { _ in
                SpringKeyframe(1.08, duration: 0.18)
                SpringKeyframe(0.97, duration: 0.14)
                SpringKeyframe(1, duration: 0.22)
            }
            .accessibilityLabel("\(bird.name), the \(bird.color.displayName.lowercased()) bird")
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(Bird.allCases, id: \.self) { bird in
                BirdView(bird: bird)
            }
            BirdView(bird: .blue, isReceiving: true)
        }
        .padding(24)
    }
    .background(Color(.bearBrown700))
}
