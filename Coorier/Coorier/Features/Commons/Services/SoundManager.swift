//
//  SoundPlayer.swift
//  Coorier
//
//  Created by Christopher Hardy Gunawan on 26/10/26.
//

import AVFoundation

enum SoundManager {
    private static var players: [String: AVAudioPlayer] = [:]

    static func preload(_ names: [String]) {
        for name in names where players[name] == nil {
            _ = player(named: name)
        }
    }

    static func play(_ name: String) {
        let sound = player(named: name)
        sound.currentTime = 0
        sound.play()
    }

    private static func player(named name: String) -> AVAudioPlayer {
        if let cached = players[name] {
            return cached
        }
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav"),
              let loaded = try? AVAudioPlayer(contentsOf: url) else {
            return AVAudioPlayer()
        }
        loaded.prepareToPlay()
        players[name] = loaded
        return loaded
    }
}
