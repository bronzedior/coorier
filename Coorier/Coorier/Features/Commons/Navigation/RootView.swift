//
//  RootView.swift
//  Coorier
//

import SwiftUI

struct RootView: View {
    @State private var router = AppRouter()
    @State private var gameServices: [GameMode: any GameService] = [:]

    var body: some View {
        NavigationStack(path: $router.path) {
            TitleView(
                onStart: { router.push(.hostRoom) },
                onJoin: { router.push(.joinRoom) }
            )
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
                #if DEBUG
                .onAppear {
                    let arguments = ProcessInfo.processInfo.arguments
                    if let flag = arguments.firstIndex(of: "-localGame"), router.path.isEmpty {
                        let players = arguments.dropFirst(flag + 1).first.flatMap(Int.init) ?? 4
                        let mode = GameMode.local(players: players, autoplay: arguments.contains("-autoplay"))
                        _ = makeGameService(mode)
                        router.push(.gameRoom(mode))
                    }
                    if let flag = arguments.firstIndex(of: "-openPage"), router.path.isEmpty,
                       let route = Self.debugRoutes[arguments.dropFirst(flag + 1).first ?? ""] {
                        router.push(route)
                    }
                }
                #endif
        }
        .onChange(of: NetworkRoomService.shared.session.phase) { _, phase in
            switch phase {
            case .playing:
                guard router.path.last != .gameRoom(.network) else { return }
                _ = makeGameService(.network)
                router.push(.gameRoom(.network))
            case .end:
                guard router.path.last != .end else { return }
                router.push(.end)
            default:
                break
            }
        }
    }

    #if DEBUG
    private static let debugRoutes: [String: AppRoute] = [
        "host": .hostRoom, "join": .joinRoom, "waiting": .waiting,
        "chooseAvatar": .chooseAvatar(.guest), "seating": .seating
    ]
    #endif

    private func startGame(players: Int) {
        let session = NetworkRoomService.shared.session
        if session.isHost, session.members.count >= GameEngine.minPlayers {
            session.startGame()
            guard router.path.last != .gameRoom(.network) else { return }
            _ = makeGameService(.network)
            router.push(.gameRoom(.network))
        } else {
            let mode = GameMode.local(players: players, autoplay: false)
            _ = makeGameService(mode)
            router.push(.gameRoom(mode))
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .hostRoom:
            HostRoomView(onBack: router.pop, onStart: { router.push(.chooseAvatar(.host)) })
                .toolbar(.hidden, for: .navigationBar)
        case .joinRoom:
            JoinRoomView(onBack: router.pop, onJoined: { router.push(.waiting) })
                .toolbar(.hidden, for: .navigationBar)
        case .waiting:
            WaitingView(onExit: router.popToRoot, onHostStarted: { router.push(.chooseAvatar(.guest)) })
                .toolbar(.hidden, for: .navigationBar)
        case .chooseAvatar(let role):
            chooseAvatarPage(role)
        case .seating:
            SeatingView(onBack: router.pop, onStart: startGame(players:))
                .toolbar(.hidden, for: .navigationBar)
        case .gameRoom(let mode):
            gameRoomPage(mode)
        case .end:
            EndView(onMainMenu: router.popToRoot)
                .toolbar(.hidden, for: .navigationBar)
                .navigationBarBackButtonHidden()
        }
    }

    private func chooseAvatarPage(_ role: PlayerRole) -> some View {
        ChooseAvatarView(
            onBack: router.pop,
            onConfirmed: { if role == .host { router.push(.seating) } }
        )
        .toolbar(.hidden, for: .navigationBar)
    }

    private func gameRoomPage(_ mode: GameMode) -> some View {
        GameRoomView(service: makeGameService(mode), onExit: router.popToRoot, onFinished: {
            guard router.path.last != .end else { return }
            router.push(.end)
        })
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
    }

    private func makeGameService(_ mode: GameMode) -> any GameService {
        if let service = gameServices[mode] { return service }
        let service: any GameService
        switch mode {
        case .network: service = NetworkGameService()
        case let .local(players, autoplay):
            let local = LocalGameService(playerCount: players)
            local.botsPlayMySeat = autoplay
            service = local
        }
        gameServices[mode] = service
        return service
    }
}

#Preview {
    RootView()
}
