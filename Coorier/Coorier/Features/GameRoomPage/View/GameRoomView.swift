//
//  GameRoomView.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 26/10/26.
//

import SwiftUI

struct GameRoomView: View {
    @State private var viewModel: GameRoomViewModel
    @State private var isConfirmingExit = false
    var onExit: () -> Void
    var onFinished: () -> Void

    init(
        service: any GameService,
        onExit: @escaping () -> Void = {},
        onFinished: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: GameRoomViewModel(service: service))
        self.onExit = onExit
        self.onFinished = onFinished
    }

    var body: some View {
        GeometryReader { safeArea in
            room(safeTop: safeArea.safeAreaInsets.top)
                .ignoresSafeArea()
        }
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in viewModel.noteActivity() })
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            GameRoomDebugMenu(viewModel: viewModel)
                .opacity(viewModel.isFinished ? 0 : 1)
                .padding(.trailing, 20)
                .padding(.top, 64)
        }
        #endif
        .onAppear { SoundManager.preload(["takecard", "dropcard"]) }
        .onChange(of: viewModel.isFinished, initial: false) { _, finished in
            if finished { onFinished() }
        }
        .onChange(of: viewModel.myItemIDs, initial: true) { viewModel.syncTable() }
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.passFeedback)
        .sensoryFeedback(.success, trigger: viewModel.successFeedback)
        .sensoryFeedback(.error, trigger: viewModel.errorFeedback)
        .alert("Leave the game?", isPresented: $isConfirmingExit) {
            Button("Stay", role: .cancel) {}
            Button("Leave", role: .destructive) {
                viewModel.leave()
                onExit()
            }
        } message: {
            Text("Your mail will stay on the table.")
        }
    }

    private func room(safeTop: CGFloat) -> some View {
        GeometryReader { proxy in
            let metrics = GameMetrics(size: proxy.size, safeTop: safeTop)
            ZStack(alignment: .topLeading) {
                GameScene(metrics: metrics)
                birdAndBubble(metrics)
                GameTable(metrics: metrics)
                itemsLayer(metrics)
                effects(metrics)
                hint(metrics)

                GameHeader(title: viewModel.title, sent: viewModel.sent, total: viewModel.total) {
                    isConfirmingExit = true
                }
                .padding(.top, max(metrics.safeTop - 2, 16))
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .onAppear { viewModel.tableHeight = metrics.tableDesignHeight }
            .onChange(of: proxy.size) { viewModel.tableHeight = metrics.tableDesignHeight }
        }
    }

    private func birdAndBubble(_ metrics: GameMetrics) -> some View {
        let birdOrigin = metrics.frame(CGPoint(x: 4, y: 433))
        return ZStack(alignment: .topLeading) {
            if let bird = viewModel.bird {
                BirdView(bird: bird, isReceiving: viewModel.isReceiving)
                    .scaleEffect(metrics.scale, anchor: .bottomLeading)
                    .frame(width: metrics.size.width, height: birdOrigin.y, alignment: .bottomLeading)
                    .offset(x: birdOrigin.x)

                bubble(for: bird, metrics: metrics)
            }
        }
    }

    @ViewBuilder
    private func bubble(for bird: Bird, metrics: GameMetrics) -> some View {
        Group {
            if viewModel.isReceiving {
                LineBubble(line: BirdLines.received)
                    .scaleEffect(metrics.scale, anchor: .topLeading)
                    .offset(x: 233 * metrics.scale, y: 180 * metrics.scale)
                    .transition(.scale(scale: 0.6, anchor: .leading).combined(with: .opacity))
            } else {
                RequestBubble(line: viewModel.isWrongLine ? BirdLines.wrong : viewModel.requestLine, request: bird.request)
                    .scaleEffect(metrics.scale, anchor: .topLeading)
                    .offset(x: 191 * metrics.scale, y: 175 * metrics.scale)
                    .transition(.opacity)
            }
        }
        .animation(.spring(duration: 0.3), value: viewModel.isWrongLine)
    }

    private func itemsLayer(_ metrics: GameMetrics) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(viewModel.myItems) { item in
                TableItemView(item: item, viewModel: viewModel, metrics: metrics)
                    .zIndex(zIndex(of: item))
            }
        }
        .frame(width: metrics.size.width, height: metrics.size.height, alignment: .topLeading)
    }

    private func zIndex(of item: GameItem) -> Double {
        if viewModel.draggingID == item.id { return 10 }
        if item.isSealed { return 3 }
        return item.isLetter ? 2 : 1
    }

    @ViewBuilder
    private func effects(_ metrics: GameMetrics) -> some View {
        SparkleBurst(trigger: viewModel.sparkleTrigger, radius: 130 * metrics.scale)
            .frame(width: 10, height: 10)
            .position(metrics.screen(viewModel.sparkleCenter))

        if let mark = viewModel.wrongMark {
            WrongMark(width: 62 * metrics.scale)
                .position(metrics.screen(mark.center))
                .transition(.scale(scale: 0.3).combined(with: .opacity))
                .id(mark.id)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func hint(_ metrics: GameMetrics) -> some View {
        if let hint = viewModel.hint {
            Text(hint)
                .font(.schoolbell(18))
                .foregroundStyle(Color(.neutral25))
                .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                .modifier(GlowPulse(isOn: viewModel.showsIdleHint))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(.black.opacity(0.55), in: .capsule)
                .position(x: metrics.size.width / 2, y: metrics.fromBottom(55))
                .allowsHitTesting(false)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: hint)
        }
    }

}

#Preview {
    GameRoomView(service: LocalGameService(playerCount: 4))
}
