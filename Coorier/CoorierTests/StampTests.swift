//
//  StampTests.swift
//  CoorierTests
//

import CoreGraphics
import SwiftUI
import Testing
@testable import Coorier

@MainActor
struct StampTests {

    @Test func everyShapeBuildsItsArtworkInsideItsBox() {
        for shape in StampShape.allCases {
            let size = shape.designSize
            let box = CGRect(origin: .zero, size: size)
            let bounds = StampArtwork(shape: shape).path(in: box).boundingRect
            #expect(!bounds.isEmpty)
            #expect(bounds.minX >= -0.5 && bounds.minY >= -0.5)
            #expect(bounds.maxX <= size.width + 0.5 && bounds.maxY <= size.height + 0.5)
        }
    }

    @Test func artworkScalesWithTheRequestedWidth() {
        let small = StampArtwork(shape: .square).path(in: CGRect(x: 0, y: 0, width: 40, height: 40)).boundingRect
        let large = StampArtwork(shape: .square).path(in: CGRect(x: 0, y: 0, width: 80, height: 80)).boundingRect
        #expect(abs(large.width / small.width - 2) < 0.01)
    }

    @Test func thereAreEightShapesAndEightColors() {
        #expect(StampShape.allCases.count == 8)
        #expect(StampColor.allCases.count == 8)
    }
}
