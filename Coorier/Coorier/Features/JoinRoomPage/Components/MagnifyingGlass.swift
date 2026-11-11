//
//  MagnifyingGlass.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 23/10/26.
//

import SwiftUI

struct MagnifyingGlass<Content: View>: View {
    private static var artworkSize: CGSize { CGSize(width: 402, height: 595) }
    private static var lensCenter: CGPoint { CGPoint(x: 201, y: 239.5) }
    private static var lensDiameter: CGFloat { 449 }

    let width: CGFloat
    @ViewBuilder let content: (_ lensDiameter: CGFloat) -> Content

    var body: some View {
        let scale = width / Self.artworkSize.width
        let lensDiameter = Self.lensDiameter * scale

        ZStack(alignment: .topLeading) {
            content(lensDiameter)
                .frame(width: lensDiameter, height: lensDiameter)
                .background(Color(.boneWhite100))
                .clipShape(.circle)
                .position(x: Self.lensCenter.x * scale, y: Self.lensCenter.y * scale)

            Image(.magnifier)
                .resizable()
                .frame(width: width, height: Self.artworkSize.height * scale)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .frame(width: width, height: Self.artworkSize.height * scale)
    }
}

#Preview {
    MagnifyingGlass(width: 402) { diameter in
        Image(.sealCrimsonKey)
            .resizable()
            .scaledToFit()
            .padding(diameter * 0.2)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    .background(Color.black)
}
