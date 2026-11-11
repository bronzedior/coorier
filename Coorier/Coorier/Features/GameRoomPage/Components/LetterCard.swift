//
//  LetterCard.swift
//  Coorier
//

import SwiftUI

struct LetterCard: View {
    static let designSize = CGSize(width: 180, height: 130)

    let color: LetterColor
    var width: CGFloat = Self.designSize.width

    private let contentInset = CGSize(width: 33, height: 23)
    private let stampSpacing: CGFloat = 13
    private let scribbleSize = CGSize(width: 106.4, height: 34.3)

    private var scale: CGFloat { width / Self.designSize.width }

    var body: some View {
        Image(color.cardImage)
            .resizable()
            .frame(width: width, height: Self.designSize.height * scale)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: stampSpacing * scale) {
                    Stamp(color.stampShape, color: color.stampColor, width: color.stampShape.designSize.width * scale)

                    ScribbleLines()
                        .stroke(Color(.neutral400), style: StrokeStyle(lineWidth: 1.2 * scale, lineCap: .round, lineJoin: .round))
                        .frame(width: scribbleSize.width * scale, height: scribbleSize.height * scale)
                }
                .padding(.leading, contentInset.width * scale)
                .padding(.top, contentInset.height * scale)
            }
            .compositingGroup()
            .shadow(color: .black.opacity(0.25), radius: 1 * scale, x: 0, y: 4 * scale)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Ready \(color.displayName) letter")
            .accessibilityIdentifier("ready-letter")
    }
}

struct ScribbleLines: Shape {
    private let amplitudes: [CGFloat] = [2.2, 2.4, 2]
    private let lengths: [CGFloat] = [1, 0.94, 0.7]
    private let wavelength: CGFloat = 13

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for (index, fraction) in lengths.enumerated() {
            let lineLength = rect.width * fraction
            let midY = rect.minY + rect.height * (CGFloat(index) + 0.5) / CGFloat(lengths.count)
            let amplitude = amplitudes[index]
            path.move(to: CGPoint(x: rect.minX, y: midY))
            var offset: CGFloat = 1
            while offset <= lineLength {
                let wave = amplitude * sin(2 * .pi * offset / wavelength)
                path.addLine(to: CGPoint(x: rect.minX + offset, y: midY + wave))
                offset += 1
            }
        }
        return path
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ForEach(LetterColor.allCases, id: \.self) { color in
                LetterCard(color: color)
            }
        }
        .padding(24)
    }
    .background(Color(.bearBrown700))
}
