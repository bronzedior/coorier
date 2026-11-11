//
//  SeatingGuideTooltip.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 25/10/26.
//

import SwiftUI

enum SeatingGuideStep {
    case one
    case two
    case three

    var title: String {
        switch self {
        case .one: return "That's you!"
        case .two: return "Check who's beside you"
        case .three: return "Arrange the seats!"
        }
    }

    var description: String {
        switch self {
        case .one: return "Your seat is right here"
        case .two: return "This friend is on your left"
        case .three: return "The seating matters for the gameplay!"
        }
    }

    var showsBackButton: Bool {
        self == .two
    }

    var confirmLabel: String {
        switch self {
        case .one, .two: return "Next"
        case .three: return "Got it!"
        }
    }
}

struct SeatingGuideTooltip: View {
    let step: SeatingGuideStep
    let targetFrame: CGRect
    var onBack: () -> Void
    var onNext: () -> Void
    var onClose: () -> Void

    @State private var size: CGSize = .zero

    private let nubWidth: CGFloat = 30
    private let nubHeight: CGFloat = 16
    private let gap: CGFloat = 12
    private let cardWidth: CGFloat = 300
    private let horizontalPadding: CGFloat = 18
    private let verticalPadding: CGFloat = 20
    private let nubInset: CGFloat = 44
    private let offsetX: CGFloat = 185
    private let screenInset: CGFloat = 12

    var body: some View {
        GeometryReader { proxy in
            let centerX = clampedCenterX(containerWidth: proxy.size.width)
            tooltip(nubInset: resolvedNubInset(centerX: centerX))
                .position(
                    x: centerX,
                    y: targetFrame.maxY + gap + size.height / 2
                )
        }
    }

    private func tooltip(nubInset: CGFloat) -> some View {
        content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .padding(.top, nubHeight)
            .frame(width: cardWidth, alignment: .leading)
            .background(
                SeatingGuideTooltipShape(nubWidth: nubWidth, nubHeight: nubHeight, nubInset: nubInset)
                    .fill(Color.neutral50)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 8, y: 8)
            )
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { size = proxy.size }
                        .onChange(of: proxy.size) { _, newSize in size = newSize }
                }
            )
    }

    private func clampedCenterX(containerWidth: CGFloat) -> CGFloat {
        let desired = step == .one
            ? targetFrame.midX
            : targetFrame.midX + nubInset - cardWidth / 2 + nubWidth / 2 + offsetX
        return min(
            max(desired, cardWidth / 2 + screenInset),
            containerWidth - cardWidth / 2 - screenInset
        )
    }

    private func resolvedNubInset(centerX: CGFloat) -> CGFloat {
        let cardOrigin = centerX - cardWidth / 2
        let desired = targetFrame.midX - cardOrigin - nubWidth / 2
        return min(max(desired, 32), cardWidth - nubWidth - 32)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text(step.title)
                        .font(.custom("Chelsea Market", size: 18))
                        .foregroundStyle(.neutral900)

                    Spacer()

                    closeButton
                }

                Text(step.description)
                    .font(.custom("Schoolbell-Regular", size: 18))
                    .foregroundStyle(.neutral600)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            buttons
        }
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.neutral50)
                .frame(width: 30, height: 30)
                .background(Color.neutral300)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var buttons: some View {
        HStack(spacing: 8) {
            if step.showsBackButton {
                actionButton("Back", action: onBack)
            }
            actionButton(step.confirmLabel, action: onNext)
        }
        .padding(.top, 6)
    }

    private func actionButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.custom("Schoolbell-Regular", size: 18))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.neutral200)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct SeatingGuideTooltipShape: Shape {
    let nubWidth: CGFloat
    let nubHeight: CGFloat
    let nubInset: CGFloat
    private let cornerRadius: CGFloat = 30

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(cornerRadius, (rect.height - nubHeight) / 2, rect.width / 2)
        let left = rect.minX + nubInset
        let right = left + nubWidth

        path.move(to: CGPoint(x: left, y: rect.minY + nubHeight))
        path.addQuadCurve(
            to: CGPoint(x: left + nubWidth / 2, y: rect.minY),
            control: CGPoint(x: left + nubWidth * 0.25, y: rect.minY)
        )
        path.addQuadCurve(
            to: CGPoint(x: right, y: rect.minY + nubHeight),
            control: CGPoint(x: right - nubWidth * 0.25, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY + nubHeight))
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.minY + nubHeight + radius),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + nubHeight + radius))
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.minY + nubHeight + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    SeatingGuideTooltip(
        step: .one,
        targetFrame: CGRect(x: 60, y: 120, width: 96, height: 128),
        onBack: {},
        onNext: {},
        onClose: {}
    )
}
