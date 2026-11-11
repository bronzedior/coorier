//
//  CameraPreview.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 23/10/26.
//

import RealityKit
import SwiftUI

struct CameraPreview: UIViewRepresentable {
    let view: ARView

    func makeUIView(context: Context) -> ARView {
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
