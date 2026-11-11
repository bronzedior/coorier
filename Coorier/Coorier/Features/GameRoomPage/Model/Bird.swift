//
//  Bird.swift
//  Coorier
//

import Foundation

nonisolated enum Bird: Int, CaseIterable, Codable, Sendable {
    case blue = 1
    case green
    case red
    case yellow
    case brown
    case teal
    case pink
    case purple

    init?(photo: String) {
        guard let bird = Bird.allCases.first(where: { $0.photo == photo }) else { return nil }
        self = bird
    }

    var name: String {
        switch self {
        case .blue: "Uru"
        case .green: "Oro"
        case .red: "Iri"
        case .yellow: "Eru"
        case .brown: "Ara"
        case .teal: "Ere"
        case .pink: "Eri"
        case .purple: "Aru"
        }
    }

    var photo: String { "Photo\(rawValue)-\(name)" }

    var avatarImage: String { self == .blue ? "A1-Aru" : "A\(rawValue)-\(name)" }

    var characterImage: String { "C\(rawValue)-\(name)" }

    var receivedImage: String? { self == .blue ? "Received\(rawValue)-\(name)" : nil }

    var color: LetterColor {
        switch self {
        case .blue: .blue
        case .green: .green
        case .red: .red
        case .yellow: .yellow
        case .brown: .brown
        case .teal: .teal
        case .pink: .pink
        case .purple: .purple
        }
    }

    var request: LetterColor {
        switch self {
        case .blue: .green
        case .green: .blue
        case .red: .yellow
        case .yellow: .red
        case .brown: .teal
        case .teal: .brown
        case .pink: .purple
        case .purple: .pink
        }
    }
}

nonisolated enum BirdLines {
    static let requests = [
        "Pass me the mail with this stamp",
        "Matching stamps only, please!",
        "Hand me the ones with this stamp!",
        "Give me the matching mail!"
    ]

    static let received = "Mail received!"
    static let wrong = "Whoops! This stamp only please..."
}
