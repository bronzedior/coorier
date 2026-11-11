//
//  ChooseAvatarView+NameRow.swift
//  Coorier
//

import SwiftUI

extension ChooseAvatarView {
    var nameRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text("Name")
                .font(.custom("Schoolbell-Regular", size: 18))
                .foregroundStyle(.neutral700)

            TextField("Your name", text: $nameDraft)
                .focused($nameFieldFocused)
                .submitLabel(.done)
                .keyboardType(.asciiCapable)
                .autocorrectionDisabled()
                .onSubmit { nameFieldFocused = false }
                .disabled(viewModel.isConfirmed)
                .font(.custom("Schoolbell-Regular", size: 24))
                .foregroundStyle(nameFieldFocused ? AnyShapeStyle(Color.neutral900) : AnyShapeStyle(Color.clear))
                .multilineTextAlignment(.trailing)
                .padding(.leading, nameFieldLeadingPadding)
                .overlay(alignment: .trailing) {
                    if !nameFieldFocused {
                        Text(viewModel.name.isEmpty ? "Your name" : viewModel.displayName)
                            .font(.custom("Schoolbell-Regular", size: 24))
                            .foregroundStyle(viewModel.name.isEmpty ? AnyShapeStyle(Color.neutral400) : AnyShapeStyle(Color.neutral900))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.leading, nameFieldLeadingPadding)
                            .background(.clear)
                            .allowsHitTesting(false)
                    }
                }
        }
        .contentShape(.rect)
        .onTapGesture { beginEditingName() }
        .modifier(ShakeEffect(animatableData: CGFloat(viewModel.shakeCount)))
    }

    func filterNameDraft(_ text: String) {
        viewModel.updateName(text)
        if nameDraft != viewModel.name {
            nameDraft = viewModel.name
        }
    }
}
