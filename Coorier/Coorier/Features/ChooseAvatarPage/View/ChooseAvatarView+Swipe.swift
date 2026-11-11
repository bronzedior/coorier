//
//  ChooseAvatarView+Swipe.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 26/10/26.
//

import SwiftUI

extension ChooseAvatarView {
    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                guard viewModel.isConfirmed == false else { return }
                let horizontal = abs(value.translation.width) > abs(value.translation.height)
                guard horizontal, abs(value.translation.width) > swipeThreshold else { return }
                viewModel.cyclePhoto(value.translation.width < 0 ? 1 : -1)
            }
    }
}
