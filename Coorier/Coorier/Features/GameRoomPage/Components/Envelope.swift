//
//  Envelope.swift
//  Coorier
//

import SwiftUI

struct Envelope<Insert: View>: View {
    static var designSize: CGSize { CGSize(width: 205, height: 200) }

    let color: LetterColor
    var sealProgress: CGFloat = 0
    var width: CGFloat = Self.designSize.width
    @ViewBuilder var insert: () -> Insert

    private let frontHeight: CGFloat = 135
    private let flapHeight: CGFloat = 76
    private let flapTop: CGFloat = 75
    private var frontTop: CGFloat { Self.designSize.height - frontHeight }
    private let stampInset = CGSize(width: 15, height: 11)
    private let stampScale: CGFloat = 0.9

    private var scale: CGFloat { width / Self.designSize.width }

    var body: some View {
        ZStack(alignment: .top) {
            part(color.envelopeBackImage, height: Self.designSize.height)
                .opacity(Double(1 - min(sealProgress / 0.3, 1)))

            insert()

            part(color.envelopeFrontImage, height: frontHeight)
                .mask(alignment: .bottom) {
                    Rectangle().frame(height: (frontHeight - (flapTop - frontTop) * sealProgress) * scale)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)

            part(color.envelopeFlapImage, height: flapHeight)
                .rotation3DEffect(
                    .degrees((1 - sealProgress) * 120),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .top,
                    perspective: 0.6
                )
                .opacity(Double(min(sealProgress * 2, 1)))
                .offset(y: flapTop * scale)

            stamp
        }
        .frame(width: width, height: Self.designSize.height * scale)
        .compositingGroup()
        .shadow(color: .black.opacity(0.5), radius: 5 * scale, x: -2 * scale, y: 5 * scale)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(color.displayName) mail")
    }

    private func part(_ image: ImageResource, height: CGFloat) -> some View {
        Image(image)
            .resizable()
            .frame(width: width, height: height * scale)
    }

    private var stamp: some View {
        Stamp(color.stampShape, fill: Color(.boneWhite300), width: color.stampShape.designSize.width * stampScale * scale)
            .padding(.leading, stampInset.width * scale)
            .padding(.bottom, stampInset.height * scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

extension Envelope where Insert == EmptyView {
    init(color: LetterColor, sealProgress: CGFloat = 0, width: CGFloat = 205) {
        self.init(color: color, sealProgress: sealProgress, width: width) { EmptyView() }
    }
}

#Preview("Open and sealed") {
    ScrollView {
        VStack(spacing: 24) {
            ForEach(LetterColor.allCases, id: \.self) { color in
                HStack(spacing: 16) {
                    Envelope(color: color, width: 160)
                    Envelope(color: color, sealProgress: 1, width: 160)
                }
            }
        }
        .padding(24)
    }
    .background(Color(.bearBrown700))
}
