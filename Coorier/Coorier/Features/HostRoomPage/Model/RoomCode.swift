//
//  RoomCode.swift
//  Coorier
//

import Foundation

struct RoomCode: Equatable {
    static let length = 4
    private static let tailRange = 1000
    private static let sealCount = RoomSeal.allCases.count

    let value: Int

    var text: String {
        String(format: "%0\(Self.length)d", value)
    }

    var seal: RoomSeal? {
        RoomSeal(rawValue: (value / Self.tailRange) % Self.sealCount)
    }

    private init(value: Int) {
        self.value = value
    }

    init?(text: String) {
        guard text.count == Self.length, text.allSatisfy(\.isASCII), let number = Int(text) else { return nil }
        self.init(value: number)
    }

    static func make(seal: RoomSeal, timestamp: Date = .now, salt: UInt64 = .random(in: .min ... .max)) -> RoomCode {
        let millis = UInt64(max(0, timestamp.timeIntervalSince1970 * 1000))
        let mixed = scramble(millis ^ salt)
        let sealDigit = seal.rawValue + Int(mixed % 2) * sealCount
        let tail = Int((mixed >> 8) % UInt64(tailRange))
        return RoomCode(value: sealDigit * tailRange + tail)
    }

    private static func scramble(_ input: UInt64) -> UInt64 {
        var result = input &+ 0x9E37_79B9_7F4A_7C15
        result = (result ^ (result >> 30)) &* 0xBF58_476D_1CE4_E5B9
        result = (result ^ (result >> 27)) &* 0x94D0_49BB_1331_11EB
        return result ^ (result >> 31)
    }
}
