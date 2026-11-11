//
//  WaitingView.swift
//  Coorier
//

import SwiftUI

struct WaitingView: View {
    @State private var viewModel = WaitingViewModel()
    var onExit: () -> Void = {}
    var onHostStarted: () -> Void = {}

    private let dotInterval: Duration = .milliseconds(500)

    var body: some View {
        ZStack {
            letterWithPin
                .offset(x: 10, y: -3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background { RoomBackdrop() }
        .overlay(alignment: .topLeading) {
            RoomBackButton(systemName: "rectangle.portrait.and.arrow.right", label: "Exit room", action: viewModel.requestExit)
                .padding(.leading, 16)
        }
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            WaitingDebugMenu(onForcePlay: onHostStarted)
                .padding(.trailing, 16)
        }
        #endif
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: dotInterval)
                viewModel.advanceDots()
            }
        }
        .alert("Leave the room?", isPresented: $viewModel.isExitConfirmationPresented) {
            Button("Leave", role: .destructive, action: exit)
            Button("Stay", role: .cancel) {}
        } message: {
            Text("You will go back to the main menu.")
        }
        .onChange(of: NetworkRoomService.shared.session.members.count, initial: true) { _, count in
            viewModel.playerCount = count
        }
        .onChange(of: NetworkRoomService.shared.session.phase) { _, phase in
            if phase == .seating { onHostStarted() }
        }
    }

    private func exit() {
        NetworkRoomService.shared.leave()
        onExit()
    }

    private var letterWithPin: some View {
        ZStack {
            WaitingLetter(dotCount: viewModel.dotCount, playersText: viewModel.playersText)
            Image(.roomPin)
                .offset(x: 18, y: -261)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    WaitingView()
}
