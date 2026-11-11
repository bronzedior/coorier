//
//  SendArrow.swift
//  Coorier
//

import SwiftUI

struct SendArrow: View {
    enum Direction {
        case pointingUp
        case pointingDown
    }

    var width: CGFloat = 50
    var tint: Color = Color(.boneWhite100)
    var direction: Direction = .pointingUp

    @State private var isLowered = false

    private let bobDistance: CGFloat = 12

    var body: some View {
        SendArrowShape()
            .fill(tint)
            .aspectRatio(SendArrowShape.designSize.width / SendArrowShape.designSize.height, contentMode: .fit)
            .frame(height: width)
            .rotationEffect(.degrees(direction == .pointingUp ? 90 : -90))
            .frame(width: width, height: width * SendArrowShape.designSize.width / SendArrowShape.designSize.height)
            .shadow(color: .black.opacity(0.25), radius: 0, x: width * 0.14, y: width * 0.14)
            .offset(y: isLowered ? bobDistance * width / 50 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    isLowered = true
                }
            }
            .allowsHitTesting(false)
            .accessibilityLabel(direction == .pointingUp ? "Swipe up to send" : "Drop the letter here")
    }
}

struct SendArrowShape: Shape {
    static let designSize = CGSize(width: 59.5, height: 57.5)

    private static let pathData = """
        M1.51264 27.4389 L34.6444 1.54075 C35.9574 0.514414 37.8761 1.44994 37.8761 3.11648 V13.5419 C37.8761 14.6465 38.7715
        15.5419 39.8761 15.5419 H57.4968 C58.6014 15.5419 59.4968 16.4374 59.4968 17.5419 V40.9674 C59.4968 42.072 58.6014
        42.9674 57.4968 42.9674 H39.8761 C38.7715 42.9674 37.8761 43.8628 37.8761 44.9674 V54.9128 C37.8761 56.5793 35.9574
        57.5148 34.6444 56.4885 L1.51264 30.5904 C0.488243 29.7896 0.488245 28.2396 1.51264 27.4389 Z
        """

    func path(in rect: CGRect) -> Path {
        let design = StampSVGPath.path(from: [Self.pathData], origin: .zero)
        let scale = CGAffineTransform(
            scaleX: rect.width / Self.designSize.width,
            y: rect.height / Self.designSize.height
        )
        return design.applying(scale.concatenating(CGAffineTransform(translationX: rect.minX, y: rect.minY)))
    }
}

#Preview {
    ZStack {
        EnvelopeGlow()
        Envelope(color: .blue, sealProgress: 1)
            .overlay(alignment: .top) { SendArrow().padding(.top, 6) }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.bearBrown700))
}
