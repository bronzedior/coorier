//
//  JoinRoomDebugMenu.swift
//  Coorier
//
//  Created by Fransiscus Bronzedior Driandonny Noryon on 23/10/26.
//

#if DEBUG
import SwiftUI

struct JoinRoomDebugMenu: View {
    let viewModel: JoinRoomViewModel

    var body: some View {
        Menu {
            Section("Fake a scan") {
                ForEach(RoomSeal.allCases) { seal in
                    Button(seal.accessibilityName) {
                        viewModel.simulateScan(of: seal)
                    }
                }
            }
            Button("Scan again", systemImage: "arrow.counterclockwise") {
                viewModel.resetScan()
            }
        } label: {
            Image(systemName: "ladybug.fill")
                .font(.footnote.bold())
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.black.opacity(0.55), in: .circle)
        }
        .accessibilityLabel("Debug menu")
    }
}
#endif
