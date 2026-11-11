//
//  HostRoomDebugMenu.swift
//  Coorier
//

#if DEBUG
import SwiftUI

struct HostRoomDebugMenu: View {
    let viewModel: HostRoomViewModel

    var body: some View {
        Menu {
            Section("Players \(viewModel.playerCount)/\(HostRoomViewModel.maxPlayers)") {
                Button("Add player", systemImage: "person.badge.plus") {
                    viewModel.playerCount = min(viewModel.playerCount + 1, HostRoomViewModel.maxPlayers)
                }
                Button("Remove player", systemImage: "person.badge.minus") {
                    viewModel.playerCount = max(viewModel.playerCount - 1, 1)
                }
                Button("Reset to host only", systemImage: "arrow.counterclockwise") {
                    viewModel.playerCount = 1
                }
            }
            Section("Room code \(viewModel.code.text)") {
                Button("New seal and code", systemImage: "dice") {
                    viewModel.regenerateRoom()
                }
            }
        } label: {
            Label("\(viewModel.playerCount)", systemImage: "ladybug.fill")
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
