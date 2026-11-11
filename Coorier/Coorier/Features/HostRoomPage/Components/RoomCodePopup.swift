//
//  RoomCodePopup.swift
//  Coorier
//

import SwiftUI

struct RoomCodePopup: View {
    let code: RoomCode
    let onDismiss: () -> Void

    private let cardColor = Color(red: 251 / 255, green: 247 / 255, blue: 241 / 255)

    var body: some View {
        ZStack {
            Color.black.opacity(0.62)
                .ignoresSafeArea()

            card
                .padding(.horizontal, 43)
        }
    }

    private var card: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Invite not working?")
                    .font(.chelseaMarket(17))
                Text("No worries! Your friends can enter this code on their phones")
                    .font(.schoolbell(17))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)

            codeDigits

            Button(action: onDismiss) {
                Text("Got it!")
                    .font(.schoolbell(17))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color(.secondarySystemFill), in: .capsule)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 34)
                .fill(cardColor)
                .shadow(color: .black.opacity(0.25), radius: 24, y: 8)
        }
        .accessibilityElement(children: .contain)
    }

    private var codeDigits: some View {
        HStack(spacing: 9) {
            ForEach(Array(code.text.enumerated()), id: \.offset) { _, digit in
                Text(String(digit))
                    .font(.relaxe(32))
                    .foregroundStyle(.white)
                    .frame(width: 16.8)
                    .padding(12)
                    .background(Color(.autumnRed), in: .rect(cornerRadius: 5.4))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Room code \(code.text.map(String.init).joined(separator: " "))")
    }
}

#Preview {
    RoomCodePopup(code: RoomCode(text: "9650") ?? .make(seal: .blueQuill)) {}
}
