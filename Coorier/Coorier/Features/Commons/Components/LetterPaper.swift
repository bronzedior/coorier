//
//  LetterPaper.swift
//  Coorier
//

import SwiftUI

struct LetterPaper: View {
    let size: CGSize

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color(.boneWhite100))
            .overlay(alignment: .topLeading) {
                Image(.letterPaper)
                    .resizable()
                    .frame(width: size.width * 1.1944, height: size.height * 1.3192)
                    .offset(x: -size.width * 0.0972, y: -size.height * 0.0853)
                    .opacity(0.2)
            }
            .clipShape(.rect(cornerRadius: 2))
            .shadow(color: .black.opacity(0.5), radius: 5, x: 10, y: 10)
            .overlay(RoundedRectangle(cornerRadius: 2).strokeBorder(Color(.boneWhite200), lineWidth: 2))
    }
}
