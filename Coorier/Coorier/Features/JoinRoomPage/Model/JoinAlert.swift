//
//  JoinAlert.swift
//  Coorier
//

struct JoinAlert: Equatable {
    let title: String
    let message: String

    static let stampMismatch = JoinAlert(
        title: "Wrong stamp",
        message: "That stamp is not the room you are hosting."
    )
}
