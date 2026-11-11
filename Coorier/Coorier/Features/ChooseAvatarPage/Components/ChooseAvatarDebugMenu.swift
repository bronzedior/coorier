//
//  ChooseAvatarDebugMenu.swift
//  Coorier
//

#if DEBUG
import SwiftUI

struct ChooseAvatarDebugMenu: View {
    let viewModel: ChooseAvatarViewModel

    var body: some View {
        Menu {
            Section("Avatars") {
                Button(
                    viewModel.isCurrentPhotoTaken
                        ? "Free current avatar"
                        : "Take current avatar"
                ) {
                    viewModel.toggleCurrentPhotoTaken()
                }
                Button("Reset all", systemImage: "arrow.counterclockwise") {
                    viewModel.takenAvatars = []
                }
            }
        } label: {
            Label("\(viewModel.takenAvatars.count)", systemImage: "ladybug.fill")
                .font(.footnote.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(.black.opacity(0.55), in: .capsule)
        }
        .accessibilityLabel("Debug menu")
    }
}
#endif
