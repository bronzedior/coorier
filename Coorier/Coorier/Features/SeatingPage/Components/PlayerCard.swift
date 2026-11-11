//
//  PlayerCard.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 24/10/26.
//

import SwiftUI

struct PlayerCard: View {
    let photo: String
    let name: String

    private let cardWidth: CGFloat = 96
    private let cardHeight: CGFloat = 128
    private let photoWidth: CGFloat = 83
    private let photoHeight: CGFloat = 94
    private let cornerRadius: CGFloat = 8
    private let photoCornerRadius: CGFloat = 2
    private let maxNameLength = 7
    private let truncatedNameLength = 5

    var body: some View {
        VStack(spacing: 2) {
            Image(photo)
                .resizable()
                .scaledToFill()
                .frame(width: photoWidth, height: photoHeight)
                .clipShape(RoundedRectangle(cornerRadius: photoCornerRadius, style: .continuous))
                .padding(.top, 4)

            Text(displayName)
                .font(.custom("Schoolbell-Regular", size: 18))
                .foregroundStyle(.neutral900)
                .lineLimit(1)
        }
        .frame(width: cardWidth, height: cardHeight)
        .background(.neutral50, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var displayName: String {
        guard name.count > maxNameLength else { return name }
        return "\(name.prefix(truncatedNameLength))…"
    }
}

#Preview {
    PlayerCard(photo: "Photo1-Uru", name: "Andy")
        .padding()
}
