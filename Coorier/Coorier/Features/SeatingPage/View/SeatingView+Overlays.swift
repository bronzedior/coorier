//
//  SeatingView+Overlays.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 25/10/26.
//

import SwiftUI

extension SeatingView {
    var draggedCardOverlay: some View {
        ZStack {
            if let player = viewModel.draggingPlayer, viewModel.dragAnchor != .zero {
                PlayerCard(photo: player.photo, name: player.name)
                    .rotationEffect(.degrees(viewModel.holdLift ? viewModel.dragAngle : 0))
                    .shadow(
                        color: .black.opacity(viewModel.dragShadowOpacity),
                        radius: viewModel.holdLift ? viewModel.dragShadowRadius : 0,
                        x: 0,
                        y: 0
                    )
                    .position(
                        x: viewModel.dragAnchor.midX + viewModel.dragOffset.width,
                        y: viewModel.dragAnchor.midY + viewModel.dragOffset.height
                            - (viewModel.holdLift ? viewModel.dragLiftY : 0)
                    )
            }
        }
    }

    var displacedCardOverlay: some View {
        ZStack {
            if let flight = viewModel.displacedFlight {
                PlayerCard(photo: flight.player.photo, name: flight.player.name)
                    .position(
                        x: flight.origin.midX + viewModel.displacedOffset.width,
                        y: flight.origin.midY + viewModel.displacedOffset.height
                    )
            }
        }
    }
}
