//
//  JobOfferLetter.swift
//  Coorier
//

import SwiftUI

struct JobOfferLetter: View {
    static let size = CGSize(width: 391.435, height: 507.674)

    let seal: RoomSeal
    let inviteMessage: String
    let playersText: String
    let onNotWorking: () -> Void

    private let contentWidth: CGFloat = 305.564

    var body: some View {
        VStack(spacing: 17) {
            Text("job offer letter")
                .font(.relaxe(36))
                .foregroundStyle(Color(.bearBrown))
                .fixedSize()

            letterBody
            stamp
            footer
        }
        .padding(EdgeInsets(top: 43, leading: 36, bottom: 32, trailing: 44))
        .frame(width: Self.size.width, height: Self.size.height, alignment: .top)
        .background { LetterPaper(size: Self.size) }
        .rotationEffect(.degrees(4.06))
    }

    private var letterBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Dear you,")
            Text("We are pleased to offer you a position with no salary, benefit, nor anything at all.")
        }
        .font(.schoolbell(18))
        .foregroundStyle(Color(.neutral900).opacity(0.8))
        .frame(width: contentWidth, alignment: .leading)
    }

    private var stamp: some View {
        VStack(spacing: 1) {
            Image(seal.image)
                .resizable()
                .scaledToFit()
                .frame(width: 188, height: 188)
                .rotationEffect(.degrees(-6))
                .frame(height: 175)
                .accessibilityLabel(seal.accessibilityName)

            Button(action: onNotWorking) {
                Text("not working?")
                    .font(.schoolbell(18))
                    .underline()
                    .foregroundStyle(Color(.destructive500))
                    .contentShape(.rect.inset(by: -12))
            }
            .buttonStyle(.plain)
        }
        .frame(width: 196)
    }

    private var footer: some View {
        VStack(spacing: 1) {
            Text(inviteMessage)
                .font(.schoolbell(18))
                .foregroundStyle(Color(.neutral900))
                .multilineTextAlignment(.center)

            HStack(alignment: .bottom, spacing: 13) {
                Text("Friends joined")
                    .font(.schoolbell(24))
                Text(playersText)
                    .font(.chelseaMarket(24))
            }
            .foregroundStyle(Color(.success500))
        }
        .frame(width: contentWidth)
    }
}

#Preview {
    JobOfferLetter(seal: .blueQuill, inviteMessage: "Gather your crew to get started!", playersText: "(1/8)") {}
        .padding(40)
        .background(Color.black)
}
