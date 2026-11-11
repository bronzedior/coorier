//
//  ScanLayout.swift
//  Coorier
//

import SwiftUI

struct ScanLayout {
    let diameter: CGFloat

    var controlGap: CGFloat { diameter * 0.06 }
    private var sideInset: CGFloat { diameter * 0.12 }

    private var topInset: CGFloat { sideInset }
    private var bottomInset: CGFloat { ZoomControl.height + controlGap * 2 + ScanGuide.lineWidth / 2 }

    var ringSide: CGFloat {
        min(diameter - sideInset * 2, diameter - topInset - bottomInset)
    }

    var ringOffset: CGFloat {
        (bottomInset - topInset) / 2
    }
}
