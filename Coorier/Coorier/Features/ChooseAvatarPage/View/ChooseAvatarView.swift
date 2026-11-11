//
//  ChooseAvatarView.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 24/10/26.
//

import SwiftUI

struct ChooseAvatarView: View {
    @State var viewModel = ChooseAvatarViewModel()
    @FocusState var nameFieldFocused: Bool
    @State var nameDraft = ""
    @State var isEditingName = false

    private let cardWidth: CGFloat = 360
    private let cardAspectRatio: CGFloat = 703.0 / 336.0
    private let arrowGap: CGFloat = 290
    let nameFieldLeadingPadding: CGFloat = 40
    private let confirmedDrop: CGFloat = 0
    private let keyboardLift: CGFloat = 47
    private let prohibitedSymbolSize: CGFloat = 160
    private let onShiftOffsetX: CGFloat = 50
    private let onShiftOffsetY: CGFloat = -130
    private let confirmedHold: Double = 0.8
    let swipeThreshold: CGFloat = 50

    var onBack: () -> Void = {}
    var onConfirmed: () -> Void = {}

    var body: some View {
        ZStack {
            if viewModel.isConfirmed {
                SpinningFire()
            }

            badgeCard
                .rotationEffect(.degrees(viewModel.sway), anchor: .top)
                .rotationEffect(.degrees(viewModel.swing), anchor: .top)
                .offset(x: viewModel.slide)
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
                .offset(y: cardLift)

            VStack(spacing: 24) {
                title
                    .opacity(viewModel.isConfirmed || isEditingName ? 0 : 1)

                cardContent
                    .frame(width: cardWidth)
                    .rotationEffect(.degrees(viewModel.sway), anchor: contentPivotAnchor)
                    .rotationEffect(.degrees(viewModel.swing), anchor: contentPivotAnchor)
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { viewModel.updateContentFrame(proxy.frame(in: .global)) }
                                .onChange(of: proxy.frame(in: .global)) { _, frame in viewModel.updateContentFrame(frame) }
                        }
                    }
                    .offset(x: viewModel.slide)
                    .offset(y: cardLift)
                    .gesture(swipeGesture)

                Spacer()

                if viewModel.isConfirmed {
                    WaitingText()
                } else {
                    FilledButton(
                        "This is me",
                        state: viewModel.canConfirm ? .active : .disabled,
                        size: .compact,
                        action: confirm
                    )
                        .padding(.horizontal, 32)
                        .opacity(isEditingName ? 0 : 1)
                        .overlay {
                            if !viewModel.canConfirm {
                                Color.clear
                                    .contentShape(.rect)
                                    .onTapGesture {
                                        viewModel.shake()
                                        if viewModel.name.isEmpty {
                                            beginEditingName()
                                        }
                                    }
                            }
                        }
                }
            }
            .padding(.vertical, 48)
            .ignoresSafeArea(.keyboard)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            if !viewModel.isConfirmed && !isEditingName {
                arrows
                    .transition(.opacity)
            }
        }
        .onAppear {
            if viewModel.isConfirmed {
                viewModel.unconfirm()
            }
            viewModel.startSway()
        }
        .onDisappear(perform: viewModel.stopSway)
        .onChange(of: viewModel.isConfirmed) { _, isConfirmed in
            NetworkRoomService.shared.session.updateProfile(
                name: viewModel.name,
                photo: isConfirmed ? viewModel.currentPhoto : ""
            )
        }
        .onChange(of: NetworkRoomService.shared.session.members, initial: true) { _, members in
            let myID = NetworkRoomService.shared.session.localMember.id
            let others = members.filter { $0.id != myID }
            viewModel.takeAvatars(claimedBy: others.map(\.photo))
            viewModel.takeNames(others.map(\.name))
        }
        .onChange(of: nameFieldFocused) { _, isFocused in
            if isFocused {
                isEditingName = true
                viewModel.pauseSway()
            } else {
                isEditingName = false
                viewModel.startSway()
            }
        }
        .overlay(alignment: .topLeading) {
            RoomBackButton(action: back)
                .padding(.leading, 26)
                .padding(.top, max(windowSafeTop - 2, 16))
                .opacity(isEditingName ? 0 : 1)
        }
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            ChooseAvatarDebugMenu(viewModel: viewModel)
                .padding(.trailing, 26)
                .padding(.top, max(windowSafeTop - 2, 16))
                .opacity(isEditingName ? 0 : 1)
        }
        #endif
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            shirtBackground
            dimOverlay
        }
        .ignoresSafeArea()
        .animation(.spring(duration: 0.35), value: isEditingName)
        .onChange(of: nameDraft) { _, text in filterNameDraft(text) }
        .onAppear { nameDraft = viewModel.name }
    }

    private var windowSafeTop: CGFloat {
        let windows = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }
        return windows.first?.safeAreaInsets.top ?? 0
    }

    private var cardLift: CGFloat {
        viewModel.isConfirmed ? confirmedDrop : (isEditingName ? -keyboardLift : 0)
    }

    func beginEditingName() {
        guard !viewModel.isConfirmed else { return }
        isEditingName = true
        nameFieldFocused = true
    }

    private var shirtBackground: some View {
        Image(.shirt)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    private var dimOverlay: some View {
        Color.black
            .opacity(viewModel.isConfirmed ? 0.75 : 0.5)
            .ignoresSafeArea()
    }

    private func confirm() {
        nameFieldFocused = false
        viewModel.confirm()
        Task {
            try? await Task.sleep(for: .seconds(confirmedHold))
            if viewModel.isConfirmed {
                onConfirmed()
            }
        }
    }

    private func back() {
        if viewModel.isConfirmed {
            viewModel.unconfirm()
        } else {
            onBack()
        }
    }

    private var title: some View {
        Text("Choose\nyour Badge!")
            .textCase(.uppercase)
            .font(.custom("Relaxe-Regular", size: 48))
            .foregroundStyle(.boneWhite100)
            .shadow(color: .black.opacity(0.74), radius: 0, x: 0, y: 3)
            .multilineTextAlignment(.center)
    }

    private var badgeCard: some View {
        Image(.card)
            .resizable()
            .scaledToFit()
            .frame(width: cardWidth, height: cardWidth * cardAspectRatio)
    }

    private var arrows: some View {
        HStack(spacing: arrowGap) {
            ArrowButton(direction: .left) { viewModel.cyclePhoto(-1) }
            ArrowButton(direction: .right) { viewModel.cyclePhoto(1) }
        }
    }

    private var cardContent: some View {
        VStack(spacing: 16) {
            photo

            nameRow

            dashedLine
                .overlay(alignment: .top) { NameTakenNote(isVisible: viewModel.isNameTaken) }
        }
        .frame(width: cardWidth - 100)
        .padding(.top, 100)
    }

    private var photo: some View {
        Image(viewModel.currentPhoto)
            .resizable()
            .scaledToFill()
            .frame(width: cardWidth - 100, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .saturation(viewModel.isCurrentPhotoTaken ? 0 : 1)
            .opacity(viewModel.isCurrentPhotoTaken ? 0.5 : 1)
            .overlay {
                if viewModel.isCurrentPhotoTaken {
                    ZStack {
                        ProhibitedSymbol()
                            .frame(width: prohibitedSymbolSize, height: prohibitedSymbolSize)
                            .opacity(0.7)
                            .modifier(ShakeEffect(animatableData: CGFloat(viewModel.prohibitedShakeCount)))

                        StrokedButton("On Shift", size: .medium, action: {})
                            .opacity(0.7)
                            .rotationEffect(.degrees(9))
                            .offset(x: onShiftOffsetX, y: onShiftOffsetY)
                    }
                }
            }
    }

    private var dashedLine: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
            }
            .stroke(
                .neutral400,
                style: StrokeStyle(lineWidth: 2, dash: [10, 8])
            )
        }
        .frame(height: 2)
    }

    private var contentPivotAnchor: UnitPoint {
        guard viewModel.contentFrame.height > 0 else { return .top }
        let distanceAboveContent = max(viewModel.contentFrame.minY, 0)
        return UnitPoint(x: 0.5, y: -distanceAboveContent / viewModel.contentFrame.height)
    }
}

#Preview {
    ChooseAvatarView()
}
