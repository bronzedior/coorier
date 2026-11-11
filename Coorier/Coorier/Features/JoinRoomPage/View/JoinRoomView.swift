//
//  JoinRoomView.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 23/10/26.
//

import SwiftUI

struct JoinRoomView: View {
    @State private var viewModel = JoinRoomViewModel()
    var onBack: () -> Void = {}
    var onJoined: () -> Void = {}

    private static let codePopupInsets = EdgeInsets(top: 200, leading: 40, bottom: 0, trailing: 40)

    @State private var isMagnifierLowered = false
    @State private var isCodePopupShown = false
    @State private var isKeyboardShown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            scanScreen
            codeEntry
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.scanState)
        .onChange(of: viewModel.joinedRoom) { _, room in
            guard room != nil else { return }
            if isCodePopupShown {
                closeCodeEntry()
            }
            Task {
                try? await Task.sleep(for: .seconds(0.8))
                onJoined()
            }
        }
        .task { await viewModel.startScanning() }
        .onDisappear(perform: viewModel.stopScanning)
        .alert(viewModel.joinAlert?.title ?? "", isPresented: joinAlertBinding) {
            Button("OK") {}
        } message: {
            Text(viewModel.joinAlert?.message ?? "")
        }
    }

    private var joinAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.joinAlert != nil && !isMagnifierLowered },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissJoinAlert()
                }
            }
        )
    }

    private var scanScreen: some View {
        GeometryReader { proxy in
            magnifier(width: proxy.size.width)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .offset(y: isMagnifierLowered ? proxy.size.height : 0)
        }
        .ignoresSafeArea()
        .background { RoomBackdrop() }
        .overlay(alignment: .top) { header }
        #if DEBUG
        .overlay(alignment: .bottomTrailing) {
            JoinRoomDebugMenu(viewModel: viewModel)
                .padding(.trailing, 16)
        }
        #endif
        .ignoresSafeArea(.keyboard)
    }

    private var header: some View {
        VStack(spacing: 40) {
            HStack {
                RoomBackButton(action: onBack) 
                Spacer()
                JoinWithCodeButton(action: openCodeEntry)
            }
            .padding(.horizontal, 26)

            VStack(spacing: 8) {
                Text("Scan the\nhost\u{2019}s stamp")
                    .font(.relaxe(48))
                    .textCase(.uppercase)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.4), radius: 0, x: 3, y: 3)
                    .accessibilityAddTraits(.isHeader)

                if let status = viewModel.statusText {
                    Text(status)
                        .font(.schoolbell(18))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
        }
    }

    private var codeEntry: some View {
        ZStack {
            Color.black.opacity(isMagnifierLowered ? 0.62 : 0)
                .allowsHitTesting(isMagnifierLowered)

            if isCodePopupShown {
                JoinCodePopup(
                    code: viewModel.codeText,
                    error: viewModel.codeError,
                    note: viewModel.isCheckingCode ? "Looking for the room..." : nil,
                    isKeyboardShown: isKeyboardShown,
                    onCodeChange: viewModel.updateCode,
                    onCancel: closeCodeEntry
                )
                .padding(Self.codePopupInsets)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .transition(reduceMotion ? .opacity : .move(edge: .bottom))
            }
        }
        .ignoresSafeArea()
    }

    private func openCodeEntry() {
        withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .easeIn(duration: 0.35)) {
            isMagnifierLowered = true
        } completion: {
            viewModel.showCodeEntry()
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(duration: 0.45, bounce: 0.2)) {
                isCodePopupShown = true
            } completion: {
                Task {
                    try? await Task.sleep(for: .seconds(0.15))
                    if isCodePopupShown {
                        isKeyboardShown = true
                    }
                }
            }
        }
    }

    private func closeCodeEntry() {
        isKeyboardShown = false
        withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .easeIn(duration: 0.3)) {
            isCodePopupShown = false
        } completion: {
            viewModel.dismissCodeEntry()
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(duration: 0.5, bounce: 0.2)) {
                isMagnifierLowered = false
            }
        }
    }

    private func magnifier(width: CGFloat) -> some View {
        MagnifyingGlass(width: width) { diameter in
            let layout = ScanLayout(diameter: diameter)
            ZStack {
                lensContent(layout: layout)
                ScanGuide(isLocked: isFound)
                    .frame(width: layout.ringSide, height: layout.ringSide)
                    .offset(y: -layout.ringOffset)
            }
            .frame(width: diameter, height: diameter)

            .contentShape(.circle)
            .overlay(alignment: .bottom) {
                if !viewModel.zoomOptions.isEmpty, viewModel.scanState == .scanning {
                    ZoomControl(options: viewModel.zoomOptions, selected: viewModel.zoom, onSelect: viewModel.setZoom)
                        .padding(.bottom, layout.controlGap)
                }
            }
            .simultaneousGesture(
                MagnifyGesture()
                    .onChanged { viewModel.pinchZoom(by: $0.magnification) }
                    .onEnded { _ in viewModel.endPinch() }
            )
        }
    }

    @ViewBuilder
    private func lensContent(layout: ScanLayout) -> some View {
        if let cameraView = viewModel.cameraView {
            CameraPreview(view: cameraView)
                .scaleEffect(viewModel.zoom)
                .accessibilityLabel("Camera view")
        } else {
            placeholder(layout: layout)
        }
    }

    private func placeholder(layout: ScanLayout) -> some View {
        let seal: RoomSeal = if case .found(let found) = viewModel.scanState { found } else { JoinRoomViewModel.placeholderSeal }
        return ZStack {
            Color(.boneWhite100)
            Image(.letterPaper)
                .resizable()
                .scaledToFill()
                .opacity(0.2)
            Image(seal.image)
                .resizable()
                .scaledToFit()
                .frame(width: layout.ringSide * 0.67)
                .rotationEffect(.degrees(-6))
                .offset(y: -layout.ringOffset)
                .opacity(isFound ? 1 : 0.85)
                .accessibilityLabel(seal.accessibilityName)
        }
    }

    private var isFound: Bool {
        if case .found = viewModel.scanState { true } else { false }
    }
}

#Preview {
    JoinRoomView()
}
