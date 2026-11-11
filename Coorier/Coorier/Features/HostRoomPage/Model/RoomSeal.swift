//
//  RoomSeal.swift
//  Coorier
//

import SwiftUI

enum RoomSeal: Int, CaseIterable, Identifiable {
    case amberAnchor
    case blueQuill
    case crimsonKey
    case greenEnvelope
    case violetCrown

    var id: Int { rawValue }

    var image: ImageResource {
        switch self {
        case .amberAnchor: .sealAmberAnchor
        case .blueQuill: .sealBlueQuill
        case .crimsonKey: .sealCrimsonKey
        case .greenEnvelope: .sealGreenEnvelope
        case .violetCrown: .sealVioletCrown
        }
    }

    var accessibilityName: String {
        switch self {
        case .amberAnchor: "Amber anchor seal"
        case .blueQuill: "Blue quill seal"
        case .crimsonKey: "Crimson key seal"
        case .greenEnvelope: "Green envelope seal"
        case .violetCrown: "Violet crown seal"
        }
    }

    static func random() -> RoomSeal {
        allCases.randomElement() ?? .amberAnchor
    }
}
