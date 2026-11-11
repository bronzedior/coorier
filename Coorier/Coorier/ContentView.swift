//
//  ContentView.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 22/10/26.
//

import SwiftUI
import UIKit

struct FontCheck {
    let postScript: String
    let family: String
    let sample: String
}

let fontChecks: [FontCheck] = [
    FontCheck(postScript: "Schoolbell-Regular", family: "Schoolbell", sample: "The quick brown fox"),
    FontCheck(postScript: "Relaxe-Regular", family: "Relaxe", sample: "The quick brown fox")
]

let colorGroups: [(title: String, names: [String])] = [
    ("Main Colors", ["AutumnRed", "BearBrown", "BoneWhite", "DeepTeal", "FireOrange", "ForestGreen"]),
    ("Neutral", (1...11).map { step in
        ["Neutral25", "Neutral50", "Neutral100", "Neutral200", "Neutral300", "Neutral400",
         "Neutral500", "Neutral600", "Neutral700", "Neutral800", "Neutral900"][step - 1]
    }),
    ("Secondary - Bear Brown", stride(from: 200, through: 800, by: 100).map { "BearBrown\($0)" }),
    ("Secondary - Pigeon Blue", stride(from: 200, through: 800, by: 100).map { "PigeonBlue\($0)" }),
    ("Secondary - Deep Teal", stride(from: 200, through: 500, by: 100).map { "DeepTeal\($0)" }),
    ("Secondary - Forest Green", stride(from: 200, through: 600, by: 100).map { "ForestGreen\($0)" }),
    ("Buttons - Success", stride(from: 500, through: 700, by: 100).map { "Success\($0)" }),
    ("Buttons - Warning", stride(from: 500, through: 700, by: 100).map { "Warning\($0)" }),
    ("Buttons - Destructive", stride(from: 500, through: 700, by: 100).map { "Destructive\($0)" }),
    ("Interactables - Bone White", stride(from: 100, through: 800, by: 100).map { "BoneWhite\($0)" })
]

struct ContentView: View {
    var body: some View {
        List {
            fontSection
            colorSections
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Design QA")
    }

    private var fontSection: some View {
        Section {
            ForEach(fontChecks, id: \.postScript) { font in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: FontLoader.isLoaded(font.postScript) ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(FontLoader.isLoaded(font.postScript) ? .green : .red)
                        Text(font.postScript)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    Text(font.sample)
                        .font(.custom(font.postScript, size: 22))
                }
                .padding(.vertical, 2)
            }
        } header: {
            Text("Custom Fonts")
        } footer: {
            Text("✓ = registered via UIAppFonts and loadable with UIFont(name:). If it shows ✗, the font is not in the app bundle (check target membership / Info.plist).")
        }
    }

    private var colorSections: some View {
        ForEach(colorGroups, id: \.title) { group in
            Section(group.title) {
                ForEach(group.names, id: \.self) { name in
                    let uiColor = UIColor(named: name)
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(uiColor.map(Color.init) ?? .clear)
                            .frame(width: 44, height: 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(.quaternary)
                            )
                        Image(systemName: uiColor != nil ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(uiColor != nil ? .green : .red)
                        Text(name)
                            .font(.caption.monospaced())
                    }
                }
            }
        }
    }
}

enum FontLoader {
    static func isLoaded(_ name: String) -> Bool {
        UIFont(name: name, size: 12) != nil
    }
}

#Preview {
    ContentView()
}
