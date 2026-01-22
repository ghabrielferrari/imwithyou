//
//  AudioPlayer.swift
//  ImWithYou
//
//  Created by Gabriel Ferrari on 22/01/26.
//

import AVFoundation

final class AudioPlayer {
    private var player: AVAudioPlayer?

    func playLoop(fileName: String, fileExtension: String, volume: Float = 0.35) {
        guard player == nil else { return }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Audio file not found: \(fileName).\(fileExtension)")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = -1
            p.volume = volume
            p.prepareToPlay()
            p.play()
            player = p
        } catch {
            print("Failed to play audio: \(error)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
