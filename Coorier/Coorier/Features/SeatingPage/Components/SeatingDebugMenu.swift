//
//  SeatingDebugMenu.swift
//  Coorier
//

#if DEBUG
import SwiftUI

struct SeatingDebugMenu: View {
    let viewModel: SeatingViewModel

    var body: some View {
        Menu {
            Section("Players") {
                ForEach(SeatingModel.minPlayers...SeatingModel.maxPlayers, id: \.self) { count in
                    Button("\(count) players") {
                        viewModel.seatPlayers(count: count)
                    }
                }
                Button("Reshuffle", systemImage: "dice") {
                    viewModel.seatPlayers(count: viewModel.players.count)
                }
            }
        } label: {
            Label("\(viewModel.players.count)", systemImage: "ladybug.fill")
                .font(.footnote.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(.black.opacity(0.55), in: .capsule)
        }
        .accessibilityLabel("Debug menu")
    }
}
#endif
