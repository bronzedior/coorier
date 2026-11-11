//
//  StampColor.swift
//  Coorier
//

import SwiftUI

enum StampColor: CaseIterable {
    case pigeonBlue
    case moss
    case brick
    case amber
    case chestnut
    case deepTeal
    case rose
    case plum

    var color: Color {
        switch self {
        case .pigeonBlue: Color(red: 0x2C / 255, green: 0x79 / 255, blue: 0x88 / 255)
        case .moss: Color(red: 0x46 / 255, green: 0x5A / 255, blue: 0x40 / 255)
        case .brick: Color(red: 0x83 / 255, green: 0x19 / 255, blue: 0x00 / 255)
        case .amber: Color(red: 0xE4 / 255, green: 0x8D / 255, blue: 0x21 / 255)
        case .chestnut: Color(red: 0x69 / 255, green: 0x2B / 255, blue: 0x06 / 255)
        case .deepTeal: Color(.deepTeal)
        case .rose: Color(red: 0xB5 / 255, green: 0x6D / 255, blue: 0x71 / 255)
        case .plum: Color(red: 0xA0 / 255, green: 0x4A / 255, blue: 0x79 / 255)
        }
    }
}
