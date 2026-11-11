//
//  ChooseAvatarModel.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 24/10/26.
//

import Foundation

struct ChooseAvatarModel {
    let photos = [
        "Photo1-Uru",
        "Photo2-Oro",
        "Photo3-Iri",
        "Photo4-Eru",
        "Photo5-Ara",
        "Photo6-Ere",
        "Photo7-Eri",
        "Photo8-Aru"
    ]
    let maxNameLength = 16

    func sanitized(_ name: String) -> String {
        String(name.filter { $0.isLetter && $0.isASCII })
    }

    func isTaken(_ name: String, by others: Set<String>) -> Bool {
        !name.isEmpty && others.contains(name.lowercased())
    }

    func displayName(_ name: String) -> String {
        guard name.count > maxNameLength else { return name }
        return "\(name.prefix(maxNameLength))..."
    }
}
