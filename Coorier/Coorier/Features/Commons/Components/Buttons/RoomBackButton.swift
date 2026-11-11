//
//  RoomBackButton.swift
//  Coorier
//

import SwiftUI

struct RoomBackButton: View {
    var systemName = "chevron.backward"
    var label = "Back"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 31, height: 31)
        }
        .tintedCircleStyle(Color(.fireOrange).opacity(0.45))
        .accessibilityLabel(label)
    }
}

private extension View {
    @ViewBuilder
    func tintedCircleStyle(_ tint: Color) -> some View {
        if #available(iOS 26, *) {
            buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .tint(tint)
        } else {
            buttonStyle(.plain)
                .background(tint, in: .circle)
        }
    }
}

#Preview {
    RoomBackButton {}
        .padding()
        .background(Color.black)
}
