//
//  ProhibitedSymbol.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 24/10/26.
//

import SwiftUI

struct ProhibitedSymbol: View {
    var color: Color = .destructive700
    var strokeRatio: CGFloat = 0.07

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let lineWidth = side * strokeRatio
            ZStack {
                Circle()
                    .strokeBorder(color, lineWidth: lineWidth)
                Path { path in
                    let radius = side / 2 - lineWidth
                    let offset = radius * cos(.pi / 4)
                    let center = CGPoint(x: side / 2, y: side / 2)
                    path.move(to: CGPoint(x: center.x - offset, y: center.y - offset))
                    path.addLine(to: CGPoint(x: center.x + offset, y: center.y + offset))
                }
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
            }
            .frame(width: side, height: side)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    ProhibitedSymbol()
        .frame(width: 200, height: 200)
        .padding()
}
