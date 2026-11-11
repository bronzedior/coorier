//
//  ShakeEffect.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 24/10/26.
//

import SwiftUI

struct ShakeEffect: GeometryEffect {
    var travel: CGFloat = 8
    var shakesPerCycle: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = travel * sin(animatableData * .pi * shakesPerCycle * 2)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
