//
//  GameBackdrop.swift
//  Coorier
//

import SwiftUI

struct GameScene: View {
    let metrics: GameMetrics

    private let warmTint = Color(red: 0x68 / 255, green: 0x2D / 255, blue: 0x03 / 255)
    private let fadeTop = Color(red: 112 / 255, green: 36 / 255, blue: 0).opacity(0)
    private let fadeBottom = Color(red: 0x6E / 255, green: 0x69 / 255, blue: 0x67 / 255)

    var body: some View {
        let scale = metrics.scale
        ZStack(alignment: .topLeading) {
            Color(.neutral600)

            Image(.game)
                .resizable()
                .frame(width: 402 * scale, height: 528 * scale)

            Group {
                warmTint.opacity(0.3).blendMode(.overlay)
                Color.black.opacity(0.5).blendMode(.hardLight)
            }
            .frame(width: 400 * scale, height: 533 * scale)
            .offset(x: 2 * scale, y: -5 * scale)

            LinearGradient(colors: [fadeTop, fadeBottom], startPoint: .top, endPoint: .bottom)
                .blendMode(.hardLight)
                .frame(width: 402 * scale, height: 163 * scale)
                .offset(y: 191 * scale)
        }
        .frame(width: metrics.size.width, height: metrics.tableTop + 4 * scale, alignment: .topLeading)
        .clipped()
        .compositingGroup()
        .accessibilityHidden(true)
    }
}

struct GameTable: View {
    let metrics: GameMetrics

    var body: some View {
        let scale = metrics.scale
        ZStack(alignment: .topLeading) {
            Image(.wood)
                .resizable()
                .frame(width: 434 * scale, height: 943.6 * scale)
                .offset(x: -16 * scale, y: -413.6 * scale)
                .frame(width: metrics.size.width, height: metrics.tableScreenHeight, alignment: .topLeading)
                .clipped()
                .offset(y: metrics.tableTop)

            Image(.pencil)
                .opacity(0.46)
                .scaleEffect(scale)
                .position(x: 23.5 * scale, y: metrics.fromBottom(188.5))

            Image(.stamps)
                .rotationEffect(.degrees(43))
                .scaleEffect(scale)
                .position(x: 24.7 * scale, y: metrics.fromBottom(26.9))

            Image(.stamp)
                .opacity(0.4)
                .scaleEffect(scale)
                .position(x: 353.25 * scale, y: metrics.fromBottom(46.75))
        }
        .frame(width: metrics.size.width, height: metrics.size.height, alignment: .topLeading)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
