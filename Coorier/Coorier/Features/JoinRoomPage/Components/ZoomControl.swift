//
//  ZoomControl.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 23/10/26.
//

import SwiftUI

struct ZoomControl: View {
    static let height: CGFloat = 44

    let options: [CGFloat]
    let selected: CGFloat
    let onSelect: (CGFloat) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == activeOption
                Button {
                    onSelect(option)
                } label: {
                    Text(label(for: isSelected ? selected : option, isSelected: isSelected))
                        .font(.system(size: isSelected ? 12 : 10, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.yellow : Color.white)
                        .frame(width: isSelected ? 36 : 26, height: isSelected ? 36 : 26)
                        .background(.black.opacity(0.35), in: .circle)
                        .contentShape(.circle)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Zoom \(label(for: option, isSelected: true))")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(.black.opacity(0.2), in: .capsule)
        .animation(.easeOut(duration: 0.15), value: selected)
    }

    private var activeOption: CGFloat? {
        options.last { $0 <= selected + 0.05 } ?? options.first
    }

    private func label(for value: CGFloat, isSelected: Bool) -> String {
        let isWhole = abs(value - value.rounded()) < 0.05
        let number = if value < 1 {
            String(format: ".%.0f", value * 10)
        } else {
            String(format: isWhole ? "%.0f" : "%.1f", value)
        }
        return isSelected ? "\(number)x" : number
    }
}

#Preview {
    ZoomControl(options: [0.5, 1, 3], selected: 1) { _ in }
        .padding()
        .background(Color.gray)
}
