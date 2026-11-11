//
//  JoinWithCodeButton.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 23/10/26.
//

import SwiftUI

struct JoinWithCodeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Join with code")
                .font(.chelseaMarket(17))
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .frame(height: 31)
        }
        .tintedCapsuleStyle(Color(.fireOrange).opacity(0.45))
    }
}

private extension View {
    @ViewBuilder
    func tintedCapsuleStyle(_ tint: Color) -> some View {
        if #available(iOS 26, *) {
            buttonStyle(.glassProminent)
                .buttonBorderShape(.capsule)
                .tint(tint)
        } else {
            buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(tint, in: .capsule)
        }
    }
}

#Preview {
    JoinWithCodeButton {}
        .padding()
        .background(Color.black)
}
