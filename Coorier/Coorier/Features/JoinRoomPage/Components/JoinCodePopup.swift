//
//  JoinCodePopup.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 23/10/26.
//

import SwiftUI

struct JoinCodePopup: View {
    let code: String
    let error: String?
    var note: String?
    let isKeyboardShown: Bool
    let onCodeChange: (String) -> Void
    let onCancel: () -> Void

    @FocusState private var isFieldFocused: Bool

    private let cardColor = Color(red: 245 / 255, green: 243 / 255, blue: 238 / 255)
    private let tileColor = Color.black.opacity(0.08)
    private let activeTileColor = Color.black.opacity(0.16)

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Invite not working?")
                    .font(.chelseaMarket(17))
                Text("Enter the code on the host's screen.")
                    .font(.schoolbell(15))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.top, 8)

            VStack(spacing: 8) {
                codeTiles
                if let error {
                    Text(error)
                        .font(.schoolbell(15))
                        .foregroundStyle(Color(.destructive500))
                } else if let note {
                    Text(note)
                        .font(.schoolbell(15))
                        .foregroundStyle(Color(.neutral600))
                }
            }

            Button(action: onCancel) {
                Text("Cancel")
                    .font(.schoolbell(17))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.black.opacity(0.08), in: .capsule)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 34)
                .fill(cardColor)
                .shadow(color: .black.opacity(0.25), radius: 24, y: 8)
        }
        .overlay(RoundedRectangle(cornerRadius: 34).strokeBorder(.white.opacity(0.8), lineWidth: 3))
        .accessibilityElement(children: .contain)
        .onChange(of: isKeyboardShown, initial: true) { _, isShown in
            isFieldFocused = isShown
        }
    }

    private var codeTiles: some View {
        let digits = Array(code)
        return HStack(spacing: 10) {
            ForEach(0..<RoomCode.length, id: \.self) { index in
                Text(index < digits.count ? String(digits[index]) : " ")
                    .font(.relaxe(32))
                    .foregroundStyle(Color(.neutral900))
                    .frame(width: 40, height: 56)
                    .background(
                        index == digits.count && isFieldFocused ? activeTileColor : tileColor,
                        in: .rect(cornerRadius: 6)
                    )
            }
        }
        .background {
            TextField("Room code", text: Binding(get: { code }, set: onCodeChange))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFieldFocused)
                .opacity(0.01)
        }
        .contentShape(.rect)
        .onTapGesture { isFieldFocused = true }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Room code")
        .accessibilityValue(code.isEmpty ? "Empty" : code.map(String.init).joined(separator: " "))
    }
}

#Preview {
    JoinCodePopup(code: "96", error: nil, isKeyboardShown: true, onCodeChange: { _ in }, onCancel: {})
        .padding(.horizontal, 40)
        .frame(maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
}
