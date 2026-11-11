//
//  SeatingView.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 25/10/26.
//

import SwiftUI

struct SeatingView: View {
    @State var viewModel = SeatingViewModel()
    @State private var pulseVisible = false
    @State private var pulsePlayerID: Int?
    @State private var pulseAmplitude: CGFloat = 0

    private let bookOverscan: CGFloat = 85
    private let bookOffsetX: CGFloat = 10
    private let seatGridHorizontalSpacing: CGFloat = 10
    private let seatGridVerticalSpacing: CGFloat = 16
    private let dashedPlaceholderScale: CGFloat = 0.98
    private let topControlsPadding: CGFloat = 48

    var onBack: () -> Void = {}
    var onStart: (Int) -> Void = { _ in }

    var body: some View {
        ZStack {
            woodBackground
            bookBackground

            seatGrid

            VStack(spacing: 8) {
                title
                subtitle

                Spacer()

                FilledButton(
                    "Let's Work",
                    state: canStart ? .active : .disabled,
                    size: .compact
                ) {
                    SoundManager.play("clickbutton")
                    onStart(viewModel.players.count)
                }
                    .disabled(!canStart)
                    .padding(.bottom)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 48)
        }
        .overlay(alignment: .topLeading) {
            RoomBackButton(action: onBack)
                .padding(.leading, 26)
                .padding(.top, topControlsPadding)
        }
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            SeatingDebugMenu(viewModel: viewModel)
                .padding(.trailing, 16)
                .padding(.top, topControlsPadding)
        }
        #endif
        .overlay {
            if let step = viewModel.guideStep, let target = viewModel.guideTargetFrame() {
                SeatingGuideTooltip(
                    step: step,
                    targetFrame: target,
                    onBack: { viewModel.backGuide() },
                    onNext: { viewModel.advanceGuide() },
                    onClose: { viewModel.endGuide() }
                )
                .id(step)
                .transaction { $0.animation = nil }
            }
        }
        .overlay {
            ZStack {
                displacedCardOverlay
                draggedCardOverlay
            }
            .allowsHitTesting(false)
        }
        .onAppear {
            SoundManager.preload(["takecard", "dropcard", "clickbutton"])
            viewModel.onSwap = { NetworkRoomService.shared.session.swapSeats($0, $1) }
            viewModel.beginGuide()
        }
        .onChange(of: NetworkRoomService.shared.session.members, initial: true) { _, members in
            viewModel.apply(members, hostID: NetworkRoomService.shared.session.hostID)
        }
        .onChange(of: viewModel.guideStep) { _, step in
            if step == .three {
                pulsePlayerID = viewModel.guideTargetPlayer?.id
                pulseVisible = true
                withAnimation(.spring(duration: 0.25)) {
                    pulseAmplitude = 1
                }
            } else {
                withAnimation(.spring(duration: 0.25)) {
                    pulseAmplitude = 0
                }
                Task {
                    try? await Task.sleep(for: .seconds(0.3))
                    if !Task.isCancelled, viewModel.guideStep != .three {
                        pulseVisible = false
                        pulsePlayerID = nil
                    }
                }
            }
        }
        .coordinateSpace(name: "seating")
    }

    private var canStart: Bool {
        viewModel.guideStep == nil
            && !NetworkRoomService.shared.session.members.isEmpty
            && NetworkRoomService.shared.session.members.allSatisfy { !$0.photo.isEmpty }
    }

    private var woodBackground: some View {
        Image(.wood)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    private var bookBackground: some View {
        Image(.book)
            .resizable()
            .scaledToFit()
            .padding(.leading, -bookOverscan)
            .offset(x: bookOffsetX)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .horizontal)
    }

    private var seatGrid: some View {
        VStack(spacing: seatGridVerticalSpacing) {
            seatRow(1)
            seatRow(2)
            seatRow(3)
        }
        .animation(.spring(duration: viewModel.dragSettleDuration), value: viewModel.players)
    }

    private func seatRow(_ row: Int) -> some View {
        HStack(spacing: seatGridHorizontalSpacing) {
            ForEach(1...3, id: \.self) { column in
                seatCell(row: row, column: column)
            }
        }
        .zIndex(rowContainsDraggingPlayer(row) ? 1 : 0)
    }

    private func rowContainsDraggingPlayer(_ row: Int) -> Bool {
        (1...3).contains { viewModel.isDraggingCell(row: row, column: $0) }
    }

    private func seatCell(row: Int, column: Int) -> some View {
        Group {
            if row == 2 && column == 2 {
                Color.clear.frame(width: 96, height: 128)
            } else if let player = viewModel.playerAt(row: row, column: column) {
                seatedCard(player: player, row: row, column: column)
            } else {
                SeatCard()
                    .opacity(0.35)
            }
        }
        .zIndex(viewModel.isDraggingCell(row: row, column: column) ? 1 : 0)
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        viewModel.cellFrames[SeatingModel.cellKey(row: row, column: column)] =
                            proxy.frame(in: .named("seating"))
                    }
                    .onChange(of: proxy.frame(in: .named("seating"))) { _, frame in
                        viewModel.cellFrames[SeatingModel.cellKey(row: row, column: column)] = frame
                    }
            }
        }
    }

    private func seatedCard(player: Player, row: Int, column: Int) -> some View {
        let isDragging = viewModel.draggingPlayer?.id == player.id
        let isTarget = viewModel.hoveredPlayer?.id == player.id && !isDragging
        let isPulseCard = pulseVisible
            && pulsePlayerID == player.id
            && !isDragging
        return ZStack {
            if viewModel.showDragPlaceholder && isDragging {
                SeatCard()
                    .scaleEffect(dashedPlaceholderScale)
                    .transition(.opacity)
            }
            if isPulseCard {
                TimelineView(.animation) { context in
                    cardBody(
                        player: player,
                        isTarget: isTarget,
                        isDragging: isDragging,
                        phase: pulsePhase(at: context.date),
                        amplitude: pulseAmplitude
                    )
                }
            } else {
                cardBody(player: player, isTarget: isTarget, isDragging: isDragging, phase: 0, amplitude: 0)
            }
        }
        .contentShape(.rect)
        .gesture(
            DragGesture(minimumDistance: 4)
                .onChanged { value in
                    if viewModel.draggingPlayer == nil {
                        SoundManager.play("takecard")
                        viewModel.startDrag(player: player, row: row, column: column)
                    }
                    viewModel.dragChanged(translation: value.translation, row: row, column: column)
                }
                .onEnded { _ in
                    SoundManager.play("dropcard")
                    viewModel.endDrag(player: player)
                }
        )
        .onTapGesture {
            viewModel.endGuide()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(player.name)
        .accessibilityIdentifier(player.id == viewModel.hostPlayerID ? "host-seat" : "player-seat-\(player.id)")
        .accessibilityHint(player.id == viewModel.hostPlayerID ? "Host seat is fixed" : "Hold and drag to rearrange")
    }

    private func cardBody(
        player: Player,
        isTarget: Bool,
        isDragging: Bool,
        phase: CGFloat,
        amplitude: CGFloat
    ) -> some View {
        PlayerCard(photo: player.photo, name: player.name)
            .opacity(isDragging || viewModel.displacedFlight?.player.id == player.id ? 0 : 1)
            .scaleEffect((isTarget ? 1.05 : 1) * (1 + 0.06 * phase * amplitude))
            .rotationEffect(.degrees(viewModel.dragAngle * Double(amplitude)))
            .shadow(
                color: .black.opacity(viewModel.dragShadowOpacity * Double(amplitude)),
                radius: viewModel.dragShadowRadius * amplitude
            )
            .offset(y: -viewModel.dragLiftY * amplitude)
            .overlay {
                if isTarget {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.boneWhite100, lineWidth: 3)
                }
            }
    }

    private func pulsePhase(at date: Date) -> CGFloat {
        let period = 1.2
        let time = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: period) / period
        return CGFloat((1 - cos(2 * .pi * time)) / 2)
    }

    private var title: some View {
        Text("Who's Where?")
            .textCase(.uppercase)
            .font(.custom("Relaxe-Regular", size: 48))
            .foregroundStyle(.boneWhite100)
            .multilineTextAlignment(.center)
    }

    private var subtitle: some View {
        Text("Hold and drag to arrange position")
            .font(.custom("Schoolbell-Regular", size: 18))
            .foregroundStyle(.boneWhite100)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    SeatingView()
}
