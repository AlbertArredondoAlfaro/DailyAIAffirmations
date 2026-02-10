//
//  AudioManager.swift
//  Daily Affirmations
//
//  Created by Albert Bit Dj on 10/2/26.
//

import AVFoundation
import Combine
import Foundation

@MainActor
final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @Published private(set) var isMuted: Bool

    private let defaults: UserDefaults
    private let audioFiles = [
        "mantra-01",
        "mantra-02",
        "mantra-03",
        "mantra-04"
    ]
    private var player: AVAudioPlayer?
    private var currentTrackName: String?
    private var sessionTrackName: String?

    private init(
        defaults: UserDefaults = .standard
    ) {
        self.defaults = defaults
        self.isMuted = defaults.bool(forKey: DefaultsKeys.isAudioMuted)
    }

    func startIfNeeded() {
        guard !isMuted else { return }
        configureAudioSession()
        preparePlayer()
        player?.play()
    }

    func stop() {
        player?.stop()
    }

    func toggleMute() {
        setMuted(!isMuted)
    }

    func setMuted(_ muted: Bool) {
        isMuted = muted
        defaults.set(muted, forKey: DefaultsKeys.isAudioMuted)
        if muted {
            stop()
        } else {
            startIfNeeded()
        }
    }

    private func preparePlayer() {
        let trackName = sessionTrackName ?? selectTrackForSession()
        guard trackName != currentTrackName else { return }
        guard let url = Bundle.main.url(forResource: trackName, withExtension: "mp3") else {
            return
        }
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.numberOfLoops = -1
            newPlayer.volume = 0.7
            newPlayer.prepareToPlay()
            player = newPlayer
            currentTrackName = trackName
        } catch {
            player = nil
            currentTrackName = nil
        }
    }

    private func selectTrackForSession() -> String {
        let lastTrack = defaults.string(forKey: DefaultsKeys.lastTrackName)
        var choices = audioFiles
        if let lastTrack, choices.count > 1 {
            choices.removeAll { $0 == lastTrack }
        }
        let selected = choices.randomElement() ?? audioFiles.first ?? "mantra-01"
        sessionTrackName = selected
        defaults.set(selected, forKey: DefaultsKeys.lastTrackName)
        return selected
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.ambient, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            // If audio session setup fails, skip playback silently.
        }
    }

    private enum DefaultsKeys {
        static let isAudioMuted = "audio.muted"
        static let lastTrackName = "audio.lastTrackName"
    }
}
