//
//  GameRoomViewModel+Gestures.swift
//  Coorier
//

import SwiftUI

extension GameRoomViewModel {
    private var passDistance: CGFloat { 150 }
    private var deliverDistance: CGFloat { 170 }
    private var offscreen: CGFloat { TableLayout.designWidth + 160 }

    func dragChanged(_ item: GameItem, translation: CGSize) {
        guard combining == nil else { return }
        if draggingID != item.id {
            SoundManager.play("takecard")
        }
        setDragging(item.id, translation: translation)
    }

    func dragEnded(_ item: GameItem, translation: CGSize, predicted: CGSize) {
        setDragging(nil)
        guard combining == nil else { return }
        let horizontal = abs(predicted.width) > abs(predicted.height)

        if item.isLetter, let mail = mailUnder(item, translation: translation) {
            dropLetter(item, on: mail, translation: translation)
        } else if horizontal, abs(predicted.width) > passDistance {
            pass(item, predicted.width < 0 ? .left : .right, translation: translation)
        } else if item.isSealed, !horizontal, predicted.height < -deliverDistance {
            deliver(item, translation: translation)
        } else {
            settle(item, translation: translation)
        }
    }
    private func pass(_ item: GameItem, _ direction: PassDirection, translation: CGSize) {
        firePass()
        setMotion(item.id) { $0.offset = translation }
        withAnimation(.easeIn(duration: 0.28)) {
            setMotion(item.id) { motion in
                motion.offset = CGSize(width: direction == .left ? -offscreen : offscreen, height: translation.height * 1.4)
            }
        }
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(0.28))
            self?.service.send(.pass(item: item.id, direction: direction))
            await self?.recoverIfStillHere(item.id)
        }
    }

    private func deliver(_ item: GameItem, translation: CGSize) {
        let spot = spot(for: item.id)
        guard canDeliver(item) else {
            showWrong(at: spot.center)
            return refuse(item, translation: translation)
        }
        let target = CGSize(
            width: TableLayout.birdTarget.x - spot.center.x,
            height: TableLayout.birdTarget.y - spot.center.y
        )
        setMotion(item.id) { $0.offset = translation }
        withAnimation(.easeIn(duration: 0.4)) {
            setMotion(item.id) { motion in
                motion.offset = target
                motion.scale = 0.25
                motion.opacity = 0
            }
        }
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(0.4))
            SoundManager.play("dropcard")
            self?.service.send(.deliver(item: item.id))
            self?.showReceived()
        }
    }

    private func dropLetter(_ letter: GameItem, on mail: GameItem, translation: CGSize) {
        if let rejection = GameEngine.combineRejection(letter: letter, mail: mail, by: myID) {
            if rejection == .wrongCombination {
                showWrong(at: spot(for: mail.id).center)
            }
            return refuse(letter, translation: translation)
        }
        combine(letter, into: mail, translation: translation)
    }

    private func combine(_ letter: GameItem, into mail: GameItem, translation: CGSize) {
        let mailSpot = spot(for: mail.id)
        let letterSpot = spot(for: letter.id)
        setMotion(letter.id) { $0.offset = translation }
        withAnimation(.easeInOut(duration: 0.25)) {
            setMotion(letter.id) { motion in
                motion.offset = CGSize(
                    width: mailSpot.center.x - letterSpot.center.x,
                    height: mailSpot.center.y - letterSpot.center.y - 60
                )
                motion.scale = 0.9
            }
        }
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(0.25))
            self?.setMotion(letter.id) { $0.opacity = 0 }
            self?.setCombining(Combining(letterID: letter.id, mailID: mail.id))
            withAnimation(.easeIn(duration: 0.3)) {
                self?.setCombining(Combining(letterID: letter.id, mailID: mail.id, insertProgress: 1))
            }
            try? await Task.sleep(for: .seconds(0.3))
            withAnimation(.easeInOut(duration: 0.3)) { self?.setSeal(mail.id, 1) }
            SoundManager.play("dropcard")
            self?.fireSparkles(at: mailSpot.center)
            try? await Task.sleep(for: .seconds(0.35))
            self?.service.send(.combine(letter: letter.id, mail: mail.id))
            self?.setCombining(nil)
            self?.moveToSealedSpotIfFree(mail.id)
        }
    }

    private func settle(_ item: GameItem, translation: CGSize) {
        let current = spot(for: item.id)
        let moved = CGPoint(x: current.center.x + translation.width, y: current.center.y + translation.height)
        setSpot(item.id, TableSpot(center: TableLayout.clamp(moved, height: tableHeight), angle: current.angle))
        SoundManager.play("dropcard")
    }

    private func refuse(_ item: GameItem, translation: CGSize) {
        setMotion(item.id) { $0.offset = translation }
        withAnimation(.spring(duration: 0.35, bounce: 0.3)) {
            setMotion(item.id) { $0.offset = .zero }
        }
        withAnimation(.linear(duration: 0.4)) {
            setMotion(item.id) { $0.shakes += 1 }
        }
    }

    private func recoverIfStillHere(_ id: Int) async {
        try? await Task.sleep(for: .seconds(1.5))
        guard myItemIDs.contains(id) else { return }
        withAnimation(.spring(duration: 0.4)) {
            setMotion(id) { $0 = ItemMotion() }
        }
    }

    private func canDeliver(_ item: GameItem) -> Bool {
        guard let state else { return false }
        return GameEngine.deliverRejection(item, by: myID, in: state) == nil
    }

    private func mailUnder(_ letter: GameItem, translation: CGSize) -> GameItem? {
        let start = spot(for: letter.id).center
        let point = CGPoint(x: start.x + translation.width, y: start.y + translation.height)
        let size = Envelope<EmptyView>.designSize
        return myItems.first { item in
            guard item.isMail else { return false }
            let center = spot(for: item.id).center
            let frame = CGRect(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
            return frame.insetBy(dx: 10, dy: 20).contains(point)
        }
    }
}
