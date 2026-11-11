//
//  GameItem.swift
//  Coorier
//

import Foundation

nonisolated enum PassDirection: String, Codable, Sendable {
    case left
    case right

    var opposite: PassDirection { self == .left ? .right : .left }
}

nonisolated struct GameItem: Codable, Sendable, Equatable, Identifiable {
    enum Kind: Codable, Sendable, Equatable {
        case mail
        case letter
        case sealed
    }

    let id: Int
    let color: LetterColor
    let round: Int
    var kind: Kind
    var holder: MemberID
    var arrivedFrom: PassDirection?

    var isMail: Bool { kind == .mail }

    var isLetter: Bool {
        if case .letter = kind { return true }
        return false
    }

    var isSealed: Bool {
        if case .sealed = kind { return true }
        return false
    }
}
