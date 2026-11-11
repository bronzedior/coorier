//
//  Stamp.swift
//  Coorier
//

import SwiftUI

struct Stamp: View {
    let shape: StampShape
    let fill: Color
    let width: CGFloat

    init(_ shape: StampShape, color: StampColor, width: CGFloat = 48) {
        self.init(shape, fill: color.color, width: width)
    }

    init(_ shape: StampShape, fill: Color, width: CGFloat = 48) {
        self.shape = shape
        self.fill = fill
        self.width = width
    }

    var body: some View {
        StampArtwork(shape: shape)
            .fill(fill)
            .aspectRatio(shape.aspectRatio, contentMode: .fit)
            .frame(width: width)
            .accessibilityLabel(shape.accessibilityName)
    }
}

#Preview("All 64 stamps") {
    ScrollView {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(StampShape.allCases, id: \.self) { shape in
                HStack(spacing: 14) {
                    ForEach(StampColor.allCases, id: \.self) { color in
                        Stamp(shape, color: color, width: 56)
                    }
                }
            }
        }
        .padding(20)
    }
    .background(Color(.boneWhite100))
}

#Preview("Sizes") {
    HStack(alignment: .center, spacing: 24) {
        Stamp(.star, color: .brick, width: 40)
        Stamp(.star, color: .brick, width: 90)
        Stamp(.star, color: .brick, width: 180)
    }
    .padding()
    .background(Color(.boneWhite100))
}
