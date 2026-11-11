//
//  OutlinedText.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 23/10/26.
//

import SwiftUI

struct OutlinedText: View {
    let text: String
    let font: Font
    let fill: Color
    let outline: Color
    let lineWidth: CGFloat

    private let directions = 16

    var body: some View {
        ZStack {
            ForEach(0..<directions, id: \.self) { index in
                outlineCopy(index)
            }
            Text(text)
                .font(font)
                .foregroundStyle(fill)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }

    private func outlineCopy(_ index: Int) -> some View {
        let angle = Angle.degrees(Double(index) / Double(directions) * 360)
        return Text(text)
            .font(font)
            .foregroundStyle(outline)
            .offset(
                x: lineWidth * CGFloat(cos(angle.radians)),
                y: lineWidth * CGFloat(sin(angle.radians))
            )
    }
}
