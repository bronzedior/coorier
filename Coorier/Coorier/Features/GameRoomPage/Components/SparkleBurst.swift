//
//  SparkleBurst.swift
//  Coorier
//

import SwiftUI

struct SparkleBurst: View {
    var trigger: Int
    var radius: CGFloat = 130

    @State private var progress: CGFloat = 1

    private let count = 12
    private let duration = 0.9

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { index in
                SparkleShape()
                    .fill(index.isMultiple(of: 2) ? Color(.boneWhite100) : Color(.boneWhite400))
                    .frame(width: index.isMultiple(of: 2) ? 22 : 14, height: index.isMultiple(of: 2) ? 22 : 14)
                    .modifier(SparkleFlight(
                        progress: progress,
                        angle: Double(index) / Double(count) * 2 * .pi + (index.isMultiple(of: 2) ? 0 : 0.25),
                        reach: radius * (index.isMultiple(of: 3) ? 0.7 : 1)
                    ))
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onChange(of: trigger) {
            var reset = Transaction()
            reset.disablesAnimations = true
            withTransaction(reset) { progress = 0 }
            Task {
                withAnimation(.easeOut(duration: duration)) { progress = 1 }
            }
        }
    }
}

private struct SparkleFlight: ViewModifier, Animatable {
    var progress: CGFloat
    let angle: Double
    let reach: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(progress < 0.3 ? progress / 0.3 : 1 - (progress - 0.3) / 0.7)
            .rotationEffect(.degrees(progress * 90))
            .offset(x: cos(angle) * reach * progress, y: sin(angle) * reach * progress)
            .opacity(progress < 1 ? 1 : 0)
    }
}

struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let inner = min(rect.width, rect.height) * 0.12
        var path = Path()
        path.move(to: CGPoint(x: center.x, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: center.y), control: CGPoint(x: center.x + inner, y: center.y - inner))
        path.addQuadCurve(to: CGPoint(x: center.x, y: rect.maxY), control: CGPoint(x: center.x + inner, y: center.y + inner))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: center.y), control: CGPoint(x: center.x - inner, y: center.y + inner))
        path.addQuadCurve(to: CGPoint(x: center.x, y: rect.minY), control: CGPoint(x: center.x - inner, y: center.y - inner))
        path.closeSubpath()
        return path
    }
}

struct EnvelopeGlow: View {
    var radius: CGFloat = 170

    var body: some View {
        RadialGradient(
            colors: [Color(.boneWhite300).opacity(0.8), Color(.boneWhite500).opacity(0.35), .clear],
            center: .center,
            startRadius: 0,
            endRadius: radius
        )
        .frame(width: radius * 2, height: radius * 2)
        .blendMode(.screen)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct SparkleBurstPreview: View {
    @State private var trigger = 0

    var body: some View {
        ZStack {
            EnvelopeGlow()
            Envelope(color: .blue, sealProgress: 1)
            SparkleBurst(trigger: trigger)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.bearBrown700))
        .onTapGesture { trigger += 1 }
    }
}

#Preview {
    SparkleBurstPreview()
}
