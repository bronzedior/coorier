//
//  AppRoute.swift
//  Coorier
//

enum PlayerRole: Hashable {
    case host
    case guest
}

enum GameMode: Hashable {
    case network
    case local(players: Int, autoplay: Bool)
}

enum AppRoute: Hashable {
    case hostRoom
    case joinRoom
    case waiting
    case chooseAvatar(PlayerRole)
    case seating
    case gameRoom(GameMode)
    case end
}
