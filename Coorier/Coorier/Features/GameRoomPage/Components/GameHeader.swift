//
//  GameHeader.swift
//  Coorier
//

import SwiftUI

struct GameHeader: View {
    let title: String
    let sent: Int
    let total: Int
    var onExit: () -> Void = {}

    private let lineHeight: CGFloat = 25

    var body: some View {
        HStack(alignment: .center) {
            RoomBackButton(systemName: "rectangle.portrait.and.arrow.right", label: "Exit game", action: onExit)

            Spacer()

            Text(title)
                .font(.chelseaMarket(16))
                .frame(height: lineHeight)

            Spacer()

            VStack(alignment: .leading, spacing: 5) {
                Text("\(sent)/\(total)")
                    .font(.chelseaMarket(32))
                    .contentTransition(.numericText(value: Double(sent)))
                    .frame(height: lineHeight)
                Text("Mail Sent")
                    .font(.schoolbell(16))
                    .frame(height: lineHeight)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(sent) of \(total) mails sent")
        }
        .foregroundStyle(Color(.neutral25))
        .padding(.horizontal, 26)
        .padding(.bottom, 10)
    }
}

#Preview {
    GameHeader(title: "Adulting 101", sent: 1, total: 2)
        .padding(.vertical, 40)
        .background(Color(.bearBrown700))
}
