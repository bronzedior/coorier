//
//  HostRoomView.swift
//  Coorier
//

import SwiftUI

struct HostRoomView: View {
    @State private var viewModel = HostRoomViewModel()
    var onBack: () -> Void = {}
    var onStart: () -> Void = {}

    var body: some View {
        ZStack {
            letterWithPin
                .offset(x: 10, y: -3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background { RoomBackdrop() }
        .overlay(alignment: .topLeading) {
            RoomBackButton(action: leave)
            .padding(.leading, 26)
        }
        .overlay(alignment: .bottom) {
            FilledButton(
                "Ready for work",
                state: viewModel.canStart ? .active : .disabled,
                size: .compact,
                action: start
            )
                .padding(.bottom, 47)
        }
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            HostRoomDebugMenu(viewModel: viewModel)
                .padding(.trailing, 16)
        }
        #endif
        .overlay {
            if viewModel.isCodePopupPresented {
                RoomCodePopup(code: viewModel.code, onDismiss: viewModel.dismissCodePopup)
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.95)), removal: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.isCodePopupPresented)
        .onAppear(perform: viewModel.openRoom)
        .onChange(of: NetworkRoomService.shared.session.members.count, initial: true) { _, count in
            viewModel.playerCount = max(count, 1)
        }
    }

    private func start() {
        NetworkRoomService.shared.session.startSeating()
        onStart()
    }

    private func leave() {
        viewModel.closeRoom()
        onBack()
    }

    private var letterWithPin: some View {
        ZStack {
            JobOfferLetter(
                seal: viewModel.seal,
                inviteMessage: viewModel.inviteMessage,
                playersText: viewModel.playersText,
                onNotWorking: viewModel.showCodePopup
            )
            Image(.roomPin)
                .offset(x: 18, y: -261)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    HostRoomView()
}
