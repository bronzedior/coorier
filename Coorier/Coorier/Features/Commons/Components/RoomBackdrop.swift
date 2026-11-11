//
//  RoomBackdrop.swift
//  Coorier
//

import SwiftUI

struct RoomBackdrop: View {
    var body: some View {
        Image(.cover)
            .resizable()
            .scaledToFill()
            .overlay(Color.black.opacity(0.48))
            .ignoresSafeArea()
    }
}
