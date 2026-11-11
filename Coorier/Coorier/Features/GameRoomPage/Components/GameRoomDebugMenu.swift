//
//  GameRoomDebugMenu.swift
//  Coorier
//

#if DEBUG
import SwiftUI

struct GameRoomDebugMenu: View {
    @Bindable var viewModel: GameRoomViewModel

    var body: some View {
        Menu {
            Toggle("Show idle hint now", isOn: $viewModel.forceIdleHint)
            if let local = viewModel.service as? LocalGameService {
                localSections(local)
            }
        } label: {
            Label(viewModel.forceIdleHint ? "Idle on" : "Debug", systemImage: "ladybug.fill")
                .font(.footnote.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(height: 32)
                .background(.black.opacity(0.55), in: .capsule)
        }
        .accessibilityLabel("Debug menu")
    }

    @ViewBuilder
    private func localSections(_ local: LocalGameService) -> some View {
        Section("Table") {
            ForEach(GameEngine.minPlayers...Bird.allCases.count, id: \.self) { count in
                Button("Restart with \(count) players") { local.restart(playerCount: count) }
            }
        }
        Section("Play as") {
            ForEach(local.members) { member in
                Button {
                    local.myID = member.id
                } label: {
                    Label(seatLabel(member, in: local), systemImage: member.id == local.myID ? "checkmark" : "person")
                }
            }
        }
        Toggle("Bots playing", isOn: Binding(get: { local.botsEnabled }, set: { local.botsEnabled = $0 }))
        Toggle("Bots play my seat too", isOn: Binding(get: { local.botsPlayMySeat }, set: { local.botsPlayMySeat = $0 }))
    }

    private func seatLabel(_ member: RoomMember, in local: LocalGameService) -> String {
        let bird = local.state?.birds[member.id]
        let sent = local.state?.sentCount(for: member.id) ?? 0
        return "\(member.name) (\(bird?.color.displayName ?? "?"), \(sent)/\(GameState.mailsPerPlayer))"
    }
}
#endif
