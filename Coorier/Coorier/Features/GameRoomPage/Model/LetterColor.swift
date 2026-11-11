//
//  LetterColor.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 26/10/26.
//

import SwiftUI

nonisolated enum LetterColor: String, CaseIterable, Codable, Sendable {
    case blue
    case brown
    case green
    case pink
    case purple
    case red
    case teal
    case yellow
}

extension LetterColor {
    var stampShape: StampShape {
        switch self {
        case .blue: .circle
        case .brown: .triangle
        case .green: .diamond
        case .pink: .oval
        case .purple: .rectangle
        case .red: .hexagon
        case .teal: .square
        case .yellow: .star
        }
    }

    var stampColor: StampColor {
        switch self {
        case .blue: .pigeonBlue
        case .brown: .chestnut
        case .green: .moss
        case .pink: .rose
        case .purple: .plum
        case .red: .brick
        case .teal: .deepTeal
        case .yellow: .amber
        }
    }

    var cardImage: ImageResource {
        switch self {
        case .blue: .letterBlue
        case .brown: .letterBrown
        case .green: .letterGreen
        case .pink: .letterPink
        case .purple: .letterPurple
        case .red: .letterRed
        case .teal: .letterTeal
        case .yellow: .letterYellow
        }
    }

    var envelopeFrontImage: ImageResource {
        switch self {
        case .blue: .upperBlue
        case .brown: .upperBrown
        case .green: .upperGreen
        case .pink: .upperPink
        case .purple: .upperPurple
        case .red: .upperRed
        case .teal: .upperTeal
        case .yellow: .upperYellow
        }
    }

    var envelopeBackImage: ImageResource {
        switch self {
        case .blue: .bottomBlue
        case .brown: .bottomBrown
        case .green: .bottomGreen
        case .pink: .bottomPink
        case .purple: .bottomPurple
        case .red: .bottomRed
        case .teal: .bottomTeal
        case .yellow: .bottomYellow
        }
    }

    var envelopeFlapImage: ImageResource {
        switch self {
        case .blue: .sealBlue
        case .brown: .sealBrown
        case .green: .sealGreen
        case .pink: .sealPink
        case .purple: .sealPurple
        case .red: .sealRed
        case .teal: .sealTeal
        case .yellow: .sealYellow
        }
    }

    var displayName: String { rawValue.capitalized }
}
