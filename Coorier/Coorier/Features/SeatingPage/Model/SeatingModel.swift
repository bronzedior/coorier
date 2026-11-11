//
//  SeatingModel.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 25/10/26.
//

import Foundation

struct SeatingModel {
    static let minPlayers = GameEngine.minPlayers
    static let maxPlayers = Bird.allCases.count

    static let arrangements: [Int: [[Int]]] = [
        2: [[2], [], [2]],
        3: [[], [1, 3], [2]],
        4: [[2], [1, 3], [2]],
        5: [[1, 3], [1, 3], [2]],
        6: [[1, 2, 3], [1, 3], [2]],
        7: [[1, 2, 3], [1, 3], [2, 3]],
        8: [[1, 2, 3], [1, 3], [1, 2, 3]]
    ]

    static let photos = [
        "Photo1-Uru",
        "Photo2-Oro",
        "Photo3-Iri",
        "Photo4-Eru",
        "Photo5-Ara",
        "Photo6-Ere",
        "Photo7-Eri",
        "Photo8-Aru"
    ]

    static func cellKey(row: Int, column: Int) -> Int {
        row * 10 + column
    }

    static func keyRowColumn(_ key: Int) -> (row: Int, column: Int) {
        (key / 10, key % 10)
    }

    static func hostIndex(count: Int) -> Int? {
        guard let rows = arrangements[count] else { return nil }
        var index = 0
        for (rowIndex, columns) in rows.enumerated() {
            for column in columns {
                if rowIndex == 2, column == 2 { return index }
                index += 1
            }
        }
        return nil
    }

    static func placingHost(_ members: [RoomMember], hostID: MemberID) -> [RoomMember] {
        guard let host = members.first(where: { $0.id == hostID }),
              let index = hostIndex(count: members.count) else { return members }
        var ordered = members.filter { $0.id != hostID }
        ordered.insert(host, at: index)
        return ordered
    }

    static func ring(count: Int) -> [Int] {
        guard let rows = arrangements[count] else { return Array(0..<count) }
        var index = 0
        var seats: [Int: Int] = [:]
        for (row, columns) in rows.enumerated() {
            for column in columns {
                seats[cellKey(row: row + 1, column: column)] = index
                index += 1
            }
        }
        let clockwise = [11, 12, 13, 23, 33, 32, 31, 21]
        return clockwise.compactMap { seats[$0] }
    }
}

struct Player: Identifiable, Equatable {
    let id: Int
    let photo: String
    let name: String
}

struct DisplacedFlight: Equatable {
    let player: Player
    let origin: CGRect
}
