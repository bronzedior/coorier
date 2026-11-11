//
//  ARSealScanner.swift
//  Coorier
//

import ARKit
import RealityKit
import UIKit

final class ARSealScanner: NSObject, ARSessionDelegate {
    static let zoomPresets: [CGFloat] = [1, 2, 3]
    static let zoomRange: ClosedRange<CGFloat> = 1 ... 5

    private static let requiredStreak = 5
    private static let sealWidth: CGFloat = 0.031
    private static let referenceSide: CGFloat = 1024

    static var isCameraAvailable: Bool {
        ARImageTrackingConfiguration.isSupported
    }

    let view = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)

    private let onSealFound: (Int) -> Void
    private var candidate: Int?
    private var streak = 0
    private var hasReported = false

    init(onSealFound: @escaping (Int) -> Void) {
        self.onSealFound = onSealFound
        super.init()
        view.renderOptions.formUnion([
            .disableMotionBlur, .disableDepthOfField, .disableHDR, .disableGroundingShadows, .disableCameraGrain
        ])
        view.session.delegate = self
    }

    func start() -> [CGFloat] {
        candidate = nil
        streak = 0
        hasReported = false
        view.session.run(makeConfiguration(), options: [.resetTracking, .removeExistingAnchors])
        return Self.zoomPresets
    }

    func stop() {
        view.session.pause()
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        handle(anchors)
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        handle(anchors)
    }

    private func handle(_ anchors: [ARAnchor]) {
        guard !hasReported else { return }
        for case let anchor as ARImageAnchor in anchors {
            guard let index = anchor.referenceImage.name.flatMap(Int.init) else { continue }
            guard anchor.isTracked else {
                if index == candidate {
                    candidate = nil
                    streak = 0
                }
                continue
            }
            streak = index == candidate ? streak + 1 : 1
            candidate = index
            if streak >= Self.requiredStreak {
                hasReported = true
                onSealFound(index)
                return
            }
        }
    }

    private func makeConfiguration() -> ARImageTrackingConfiguration {
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = makeReferenceImages()
        configuration.maximumNumberOfTrackedImages = 1
        return configuration
    }

    private func makeReferenceImages() -> Set<ARReferenceImage> {
        let size = CGSize(width: Self.referenceSide, height: Self.referenceSide)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return Set(RoomSeal.allCases.compactMap { seal in
            let rendered = renderer.image { context in
                UIColor(resource: .boneWhite100).setFill()
                context.fill(CGRect(origin: .zero, size: size))
                UIImage(resource: seal.image).draw(in: CGRect(origin: .zero, size: size))
            }
            guard let cgImage = rendered.cgImage else { return nil }
            let reference = ARReferenceImage(cgImage, orientation: .up, physicalWidth: Self.sealWidth)
            reference.name = String(seal.rawValue)
            return reference
        })
    }
}
