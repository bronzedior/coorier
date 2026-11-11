//
//  WaitingTests.swift
//  CoorierTests
//

import CoreGraphics
import Testing
@testable import Coorier

@MainActor
struct WaitingTests {

    @Test func dotsCycleOneTwoThreeThenBackToOne() {
        let viewModel = WaitingViewModel()
        var seen = [viewModel.dotCount]
        for _ in 0 ..< 4 {
            viewModel.advanceDots()
            seen.append(viewModel.dotCount)
        }
        #expect(seen == [1, 2, 3, 1, 2])
    }

    @Test func playersTextUsesTheSameFormatAsTheHost() {
        let viewModel = WaitingViewModel(playerCount: 3)
        #expect(viewModel.playersText == "(3/\(HostRoomViewModel.maxPlayers))")
        #expect(viewModel.playersText == HostRoomViewModel(playerCount: 3, roomService: MockRoomService()).playersText)
    }

    @Test func exitAsksForConfirmation() {
        let viewModel = WaitingViewModel()
        #expect(!viewModel.isExitConfirmationPresented)
        viewModel.requestExit()
        #expect(viewModel.isExitConfirmationPresented)
    }

    @Test func routerPopsStraightBackToTheTitle() {
        let router = AppRouter()
        router.push(.joinRoom)
        router.push(.waiting)
        router.popToRoot()
        #expect(router.path.isEmpty)
    }

    @Test func backFromChooseAvatarUndoesTheConfirmation() {
        let viewModel = ChooseAvatarViewModel()
        viewModel.updateName("Axel")
        viewModel.confirm()
        #expect(viewModel.isConfirmed)
        viewModel.unconfirm()
        #expect(!viewModel.isConfirmed)
    }

    @Test func hostAndGuestRoutesDiffer() {
        #expect(AppRoute.chooseAvatar(.host) != AppRoute.chooseAvatar(.guest))
    }

    @Test func swooshChangesThePhotoAndWrapsAround() async throws {
        let viewModel = ChooseAvatarViewModel()
        let first = viewModel.photoIndex
        viewModel.cyclePhoto(1)
        try await Task.sleep(for: .milliseconds(700))
        #expect(viewModel.photoIndex == (first + 1) % viewModel.photos.count)

        viewModel.cyclePhoto(-1)
        try await Task.sleep(for: .milliseconds(700))
        #expect(viewModel.photoIndex == first)

        viewModel.cyclePhoto(-1)
        try await Task.sleep(for: .milliseconds(700))
        #expect(viewModel.photoIndex == viewModel.photos.count - 1)
    }

    @Test func tapsDuringASwooshAreIgnored() async throws {
        let viewModel = ChooseAvatarViewModel()
        let first = viewModel.photoIndex
        viewModel.cyclePhoto(1)
        viewModel.cyclePhoto(1)
        viewModel.cyclePhoto(-1)
        try await Task.sleep(for: .milliseconds(700))
        #expect(viewModel.photoIndex == (first + 1) % viewModel.photos.count)

        viewModel.cyclePhoto(1)
        try await Task.sleep(for: .milliseconds(700))
        #expect(viewModel.photoIndex == (first + 2) % viewModel.photos.count)
    }
}
