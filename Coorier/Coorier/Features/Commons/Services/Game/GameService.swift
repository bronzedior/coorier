//
//  GameService.swift
//  Coorier
//

protocol GameService: AnyObject {
    var state: GameState? { get }
    var myID: MemberID { get }

    func send(_ intent: GameIntent)
    func leave()
}
