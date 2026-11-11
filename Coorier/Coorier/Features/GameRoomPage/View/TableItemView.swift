//
//  TableItemView.swift
//  Coorier
//

import SwiftUI

struct TableItemView: View {
    let item: GameItem
    let viewModel: GameRoomViewModel
    let metrics: GameMetrics

    @State private var hasEntered = false

    var body: some View {
        let spot = viewModel.spot(for: item.id)
        let motion = viewModel.motion(for: item.id)
        let isDragging = viewModel.draggingID == item.id
        let drag = isDragging ? viewModel.dragTranslation : .zero

        artwork
            .scaleEffect(motion.scale * (isDragging ? 1.05 : 1))
            .rotationEffect(.degrees(isDragging ? 0 : spot.angle))
            .modifier(ShakeEffect(animatableData: motion.shakes))
            .opacity(motion.opacity)
            .shadow(color: .black.opacity(isDragging ? 0.35 : 0), radius: 16, y: 10)
            .contentShape(.rect)
            .gesture(dragGesture)
            .position(metrics.screen(spot.center))
            .offset(metrics.screen(motion.offset + drag))
            .offset(hasEntered ? .zero : entryOffset)
            .animation(.spring(duration: 0.3), value: isDragging)
            .animation(.spring(duration: 0.45), value: spot)
            .onAppear {
                withAnimation(.spring(duration: 0.6, bounce: 0.2).delay(entryDelay)) {
                    hasEntered = true
                }
            }
            .accessibilityHint("Swipe left or right to pass")
    }

    @ViewBuilder
    private var artwork: some View {
        let scale = metrics.scale
        if item.isLetter {
            LetterCard(color: item.color, width: LetterCard.designSize.width * scale)
        } else {
            Envelope(color: item.color, sealProgress: viewModel.sealProgress(for: item), width: 205 * scale) {
                insertedLetter
            }
            .overlay(alignment: .top) {
                if viewModel.isReadyToSend(item), viewModel.draggingID == item.id {
                    SendArrow(width: 50 * scale)
                        .padding(.top, 6 * scale)
                        .transition(.opacity.combined(with: .scale(scale: 0.6)))
                }
            }
            .background {
                if viewModel.isReadyToSend(item) {
                    EnvelopeGlow(radius: 170 * scale)
                }
            }
        }
    }

    @ViewBuilder
    private var insertedLetter: some View {
        if let combining = viewModel.combining, combining.mailID == item.id,
           let letter = viewModel.myItems.first(where: { $0.id == combining.letterID }) {
            let scale = metrics.scale
            LetterCard(color: letter.color, width: 172 * scale)
                .offset(y: (-30 + 92 * combining.insertProgress) * scale)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 6, coordinateSpace: .global)
            .onChanged { value in
                viewModel.dragChanged(item, translation: metrics.design(value.translation))
            }
            .onEnded { value in
                viewModel.dragEnded(
                    item,
                    translation: metrics.design(value.translation),
                    predicted: metrics.design(value.predictedEndTranslation)
                )
            }
    }

    private var entryOffset: CGSize {
        switch item.arrivedFrom {
        case .left: CGSize(width: -metrics.size.width, height: 0)
        case .right: CGSize(width: metrics.size.width, height: 0)
        case nil: CGSize(width: 0, height: metrics.size.height)
        }
    }

    private var entryDelay: Double {
        guard item.arrivedFrom == nil else { return 0 }
        return (item.round > 1 ? 0.7 : 0.1) + (item.isLetter ? 0.15 : 0)
    }
}
