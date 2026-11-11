//
//  SeatCard.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 24/10/26.
//

import SwiftUI

struct SeatCard: View {
    var width: CGFloat = 96
    var height: CGFloat = 128
    var cornerRadius: CGFloat = 12

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                .boneWhite100,
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [10, 8])
            )
            .frame(width: width, height: height)
    }
}

#Preview {
    SeatCard()
        .padding()
}
