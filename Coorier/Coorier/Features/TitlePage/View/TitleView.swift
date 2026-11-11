//
//  TitleView.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 23/10/26.
//

import SwiftUI

struct TitleView: View {
    private let stampsSize = CGSize(width: 120, height: 120)
    private let stampSize = CGSize(width: 200, height: 200)
    private let mascotSize = CGSize(width: 500, height: 500)
    private let buttonGapWeight = 5

    var onStart: () -> Void = {}
    var onJoin: () -> Void = {}

    var body: some View {
        ZStack {
            background
            mascot
            table
            content
        }
    }

    private var mascot: some View {
        Color.clear
            .overlay {
                Image(.mascot)
                    .resizable()
                    .frame(width: mascotSize.width, height: mascotSize.height)
            }
    }

    private var background: some View {
        Image(.cover)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    private var table: some View {
        Image(.table)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea(edges: .bottom)
    }

    private var buttons: some View {
        VStack(spacing: 24) {
            FilledButton("Start", state: .active, size: .large, action: onStart)
                .rotationEffect(.degrees(-12))

            StampButton(lines: ["Join", "Friends"], action: onJoin)
                .rotationEffect(.degrees(-12))
                .shadow(color: .black.opacity(0.2), radius: 0, x: 8, y: 8)
        }
        .background(alignment: .bottomLeading) {
            Image(.stamps)
                .resizable()
                .scaledToFit()
                .frame(width: stampsSize.width, height: stampsSize.height)
                .opacity(0.5)
                .rotationEffect(.degrees(43))
                .offset(x: -90, y: 40)
        }
        .overlay(alignment: .trailing) {
            Image(.stamp)
                .resizable()
                .scaledToFit()
                .frame(width: stampSize.width, height: stampSize.height)
                .offset(x: 90, y: 100)
        }
    }

    private var content: some View {
        VStack {
            VStack(spacing: 8) {
                Text("We're hiring a")
                    .font(.custom("Schoolbell-Regular", size: 22))
                    .foregroundStyle(.boneWhite100)
                    .padding(.bottom, 4)

                OutlinedText(
                    text: "Coorier",
                    font: .custom("Relaxe-Regular", size: 100),
                    fill: .autumnRed,
                    outline: .boneWhite100,
                    lineWidth: 8
                )
            }

            ForEach(0..<buttonGapWeight, id: \.self) { _ in
                Spacer()
            }

            buttons

            Spacer()

            Text("Bad First Draft v1.0")
                .font(.custom("Schoolbell-Regular", size: 12))
                .foregroundStyle(.boneWhite100)
        }
        .padding(.vertical, 72)
    }
}

#Preview {
    TitleView()
}
