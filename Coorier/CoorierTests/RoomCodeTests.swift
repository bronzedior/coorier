//
//  RoomCodeTests.swift
//  CoorierTests
//

import Foundation
import Testing
@testable import Coorier

@MainActor
struct RoomCodeTests {

    @Test func codeAlwaysDecodesBackToItsSeal() {
        for seal in RoomSeal.allCases {
            for salt in UInt64(0) ..< 200 {
                let code = RoomCode.make(seal: seal, timestamp: Date(timeIntervalSince1970: 1_800_000_000), salt: salt)
                #expect(code.seal == seal)
                #expect(code.text.count == RoomCode.length)
            }
        }
    }

    @Test func sameSealGetsDifferentCodesOverTime() {
        let codes = (0 ..< 50).map { offset in
            RoomCode.make(seal: .blueQuill, timestamp: Date(timeIntervalSince1970: 1_800_000_000 + Double(offset)), salt: 7)
        }
        #expect(Set(codes.map(\.value)).count > 40)
    }

    @Test func parsingRequiresExactlyFourDigits() {
        #expect(RoomCode(text: "0042")?.value == 42)
        #expect(RoomCode(text: "123") == nil)
        #expect(RoomCode(text: "12345") == nil)
        #expect(RoomCode(text: "12a4") == nil)
    }

    @Test func viewModelEnablesStartAtTwoPlayers() {
        let viewModel = HostRoomViewModel(seal: .amberAnchor, playerCount: 1)
        #expect(!viewModel.canStart)
        viewModel.playerCount = HostRoomViewModel.minPlayers
        #expect(viewModel.canStart)
        #expect(viewModel.code.seal == .amberAnchor)
    }
}
