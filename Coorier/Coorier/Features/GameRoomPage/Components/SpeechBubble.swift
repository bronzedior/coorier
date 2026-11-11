//
//  SpeechBubble.swift
//  Coorier
//

import SwiftUI

struct SpeechBubble<Content: View>: View {
    var padding = EdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 12)
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                SpeechBubbleShape()
                    .fill(Color(.boneWhite100))
                    .padding(.leading, -SpeechBubbleShape.nubWidth)
                    .shadow(color: .black.opacity(0.25), radius: 1.8, x: 8, y: 8)
            }
    }
}

struct SpeechBubbleShape: Shape {
    static let nubWidth: CGFloat = 13
    private let cornerRadius: CGFloat = 26
    private let nubDesignHeight: CGFloat = 41.5

    func path(in rect: CGRect) -> Path {
        let body = CGRect(x: rect.minX + Self.nubWidth, y: rect.minY, width: rect.width - Self.nubWidth, height: rect.height)
        let radius = min(cornerRadius, body.height / 2)
        var path = Path(roundedRect: body, cornerRadius: radius, style: .continuous)
        let nubScale = min(1, rect.height * 0.5 / nubDesignHeight)
        let baseHalfHeight = 20.6 * nubScale
        let curveDepth = max(rect.midY - rect.minY - radius, 0) >= baseHalfHeight
            ? 0
            : radius - sqrt(max(radius * radius - pow(baseHalfHeight - (rect.height / 2 - radius), 2), 0))
        path.addPath(nub(midY: rect.midY, left: rect.minX + curveDepth, scale: nubScale))
        return path
    }

    private func nub(midY: CGFloat, left: CGFloat, scale: CGFloat) -> Path {
        func point(_ posX: CGFloat, _ offsetY: CGFloat) -> CGPoint {
            CGPoint(x: left + posX, y: midY + offsetY * scale)
        }
        var path = Path()
        path.move(to: point(13, 20.93))
        path.addCurve(to: point(12.34, 13.3), control1: point(13, 18.6), control2: point(12.94, 14.89))
        path.addCurve(to: point(9.22, 9.28), control1: point(11.69, 11.57), control2: point(10.56, 10.43))
        path.addCurve(to: point(5.21, 6.04), control1: point(8.26, 8.46), control2: point(6.2, 6.83))
        path.addCurve(to: point(2.02, 3.44), control1: point(4.4, 5.4), control2: point(2.79, 4.13))
        path.addCurve(to: point(0, 0), control1: point(1.04, 2.57), control2: point(0, 1.49))
        path.addCurve(to: point(2.02, -3.44), control1: point(0, -1.49), control2: point(1.04, -2.57))
        path.addCurve(to: point(5.21, -6.04), control1: point(2.79, -4.13), control2: point(4.4, -5.4))
        path.addCurve(to: point(9.22, -9.28), control1: point(6.2, -6.83), control2: point(8.25, -8.46))
        path.addCurve(to: point(12.34, -13.29), control1: point(10.55, -10.43), control2: point(11.69, -11.57))
        path.addCurve(to: point(13, -20.58), control1: point(12.94, -14.89), control2: point(13, -18.6))
        path.closeSubpath()
        return path
    }
}

struct RequestBubble: View {
    let line: String
    let request: LetterColor

    private let width: CGFloat = 159
    private let textWidth: CGFloat = 124
    private let stampHeight: CGFloat = 41

    var body: some View {
        SpeechBubble {
            VStack(spacing: 8) {
                BubbleText(line)
                    .frame(maxWidth: textWidth)
                Stamp(request.stampShape, color: request.stampColor, width: stampHeight * request.stampShape.aspectRatio)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: width)
    }
}

struct LineBubble: View {
    let line: String

    var body: some View {
        SpeechBubble(padding: EdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 18)) {
            BubbleText(line)
        }
    }
}

private struct BubbleText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.schoolbell(16))
            .tracking(-0.43)
            .multilineTextAlignment(.center)
            .foregroundStyle(Color(.neutral800))
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 32) {
        ForEach(Array(BirdLines.requests.enumerated()), id: \.offset) { index, line in
            RequestBubble(line: line, request: LetterColor.allCases[index])
        }
        LineBubble(line: BirdLines.received)
        RequestBubble(line: BirdLines.wrong, request: .purple)
    }
    .padding(40)
    .background(Color(.bearBrown700))
}
