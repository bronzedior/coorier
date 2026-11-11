//
//  WaitingLetter.swift
//  Coorier
//

import SwiftUI

struct WaitingLetter: View {
    static let size = CGSize(width: 391.435, height: 507.674)

    let dotCount: Int
    let playersText: String

    var body: some View {
        VStack(spacing: 36) {
            Text("You\u{2019}re admitted!")
                .font(.schoolbell(18))
                .foregroundStyle(Color(.neutral900))

            title

            HStack(alignment: .bottom, spacing: 13) {
                Text("Friends joined")
                    .font(.schoolbell(24))
                Text(playersText)
                    .font(.chelseaMarket(24))
            }
            .foregroundStyle(Color(.success500))
        }
        .padding(EdgeInsets(top: 43, leading: 36, bottom: 32, trailing: 44))
        .frame(width: Self.size.width, height: Self.size.height)
        .background { LetterPaper(size: Self.size) }
        .rotationEffect(.degrees(4.06))
        .accessibilityElement(children: .combine)
    }

    private var title: some View {
        (Text("waiting for\nhost to start") + dots)
            .font(.relaxe(48))
            .foregroundStyle(Color(.autumnRed))
            .multilineTextAlignment(.center)
    }

    private var dots: Text {
        (1 ... WaitingViewModel.maxDots)
            .map { Text(".").foregroundStyle($0 <= dotCount ? Color(.autumnRed) : Color.clear) }
            .reduce(Text("")) { $0 + $1 }
    }
}

#Preview {
    WaitingLetter(dotCount: 3, playersText: "(3/8)")
        .padding(40)
        .background(Color.black)
}
