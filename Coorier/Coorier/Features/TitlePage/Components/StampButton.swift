//
//  StampButton.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 23/10/26.
//

import SwiftUI

struct StampButton: View {
    let lines: [String]
    let fontSize: CGFloat
    let action: () -> Void

    init(
        lines: [String],
        fontSize: CGFloat = 48,
        action: @escaping () -> Void
    ) {
        self.lines = lines
        self.fontSize = fontSize
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(.stampButton)

                VStack(spacing: 0) {
                    ForEach(lines, id: \.self) { line in
                        Text(line)
                            .font(.custom("Relaxe-Regular", size: fontSize))
                            .foregroundStyle(.bearBrown)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
            }
        }
    }
}

#Preview {
    StampButton(lines: ["Join", "Friends"]) {}
}
