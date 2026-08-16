import AVFoundation
import Combine
import MediaPlayer
import UIKit

class AudioService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var progress: Double = 0.0
    @Published var duration: Double = 0.0

    var formattedDuration: String {
        let totalSeconds = Int(duration.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var player: AVAudioPlayer?
    private var progressTimer: Timer?
    private var fadeTimer: Timer?
    private var wasPlayingBeforeInterruption = false
    private var currentTrackName: String = ""
    private var isLooping = false
    private var isFadingOutNearEnd = false
    var onPlaybackFinished: (() -> Void)?
    var onStopRequested: (() -> Void)?

    // MARK: - Crossfade loop state
    private var nextPlayer: AVAudioPlayer?
    private var isCrossfading = false
    private var crossfadeTimer: Timer?
    private var currentTrackURL: URL?
    private var willCrossfade = false

    override init() {
        super.init()
        configureAudioSession()
        setupInterruptionObserver()
        setupRemoteCommands()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioService: failed to configure session — \(error)")
        }
    }

    func load(track: PrayerTrack) {
        fadeTimer?.invalidate()
        fadeTimer = nil
        crossfadeTimer?.invalidate()
        crossfadeTimer = nil
        nextPlayer = nil
        isCrossfading = false
        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: track.fileExtension) else {
            print("AudioService: file not found — \(track.fileName).\(track.fileExtension)")
            return
        }
        currentTrackName = track.name
        currentTrackURL = url
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            duration = player?.duration ?? 0
            progress = 0
        } catch {
            print("AudioService: failed to load — \(error)")
        }
    }

    func play(loop: Bool = false) {
        isLooping = loop
        isFadingOutNearEnd = false
        willCrossfade = loop && duration >= AppConfig.audioCrossfadeMinTrackDuration
        player?.numberOfLoops = (loop && !willCrossfade) ? -1 : 0
        player?.volume = AppConfig.audioFadeInStartVolume
        player?.play()
        player?.setVolume(1.0, fadeDuration: AppConfig.audioFadeInDuration)
        isPlaying = true
        isPaused = false
        startProgressTimer()
        setupNowPlaying()
    }

    func pause() {
        player?.pause()
        if isCrossfading {
            nextPlayer?.pause()
            crossfadeTimer?.invalidate()
            crossfadeTimer = nil
            player?.setVolume(player?.volume ?? 0, fadeDuration: 0)
            nextPlayer?.setVolume(nextPlayer?.volume ?? 0, fadeDuration: 0)
        }
        isPlaying = false
        isPaused = true
        stopProgressTimer()
        updateNowPlayingRate(0)
    }

    func resume() {
        player?.play()
        if isCrossfading, let player, let nextPlayer {
            let remaining = max(player.duration - player.currentTime, 0.01)
            player.setVolume(0.0, fadeDuration: remaining)
            nextPlayer.play()
            nextPlayer.setVolume(1.0, fadeDuration: remaining)
            crossfadeTimer?.invalidate()
            crossfadeTimer = Timer.scheduledTimer(withTimeInterval: remaining, repeats: false) { [weak self] _ in
                self?.promoteNextPlayer()
            }
        }
        isPlaying = true
        isPaused = false
        startProgressTimer()
        updateNowPlayingRate(1)
    }

    func setLooping(_ loop: Bool) {
        isLooping = loop
        willCrossfade = loop && duration >= AppConfig.audioCrossfadeMinTrackDuration
        player?.numberOfLoops = (loop && !willCrossfade) ? -1 : 0
    }

    func stop() {
        isPaused = false
        stopProgressTimer()
        clearNowPlaying()
        fadeOut()
    }

    private func fadeOut() {
        crossfadeTimer?.invalidate()
        crossfadeTimer = nil
        let players = [player, nextPlayer].compactMap { $0 }
        guard !players.isEmpty else { return }
        let steps: Double = 20
        let interval = AppConfig.audioFadeOutDuration / steps
        let volumeSteps = players.map { $0.volume / Float(steps) }
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            var stillFading = false
            for (p, step) in zip(players, volumeSteps) {
                if p.volume > step {
                    p.volume -= step
                    stillFading = true
                }
            }
            if !stillFading {
                for p in players {
                    p.stop()
                    p.currentTime = 0
                    p.volume = 1.0
                }
                self.isPlaying = false
                self.progress = 0
                self.isCrossfading = false
                self.nextPlayer = nil
                timer.invalidate()
                self.fadeTimer = nil
            }
        }
    }

    // MARK: - Now Playing

    private func setupNowPlaying() {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = currentTrackName
        info[MPMediaItemPropertyArtist] = "Holystening"
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime ?? 0
        info[MPMediaItemPropertyPlaybackDuration] = player?.duration ?? 0
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0

        if let image = UIImage(named: "dove") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func updateNowPlayingRate(_ rate: Double) {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyPlaybackRate] = rate
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime ?? 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func updateNowPlayingElapsed() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime ?? 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func clearNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    // MARK: - Remote Commands

    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.isEnabled = true
        center.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }

        center.pauseCommand.isEnabled = true
        center.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        center.stopCommand.isEnabled = true
        center.stopCommand.addTarget { [weak self] _ in
            self?.onStopRequested?()
            return .success
        }

        center.togglePlayPauseCommand.isEnabled = true
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self else { return .commandFailed }
            self.isPlaying ? self.pause() : self.resume()
            return .success
        }
    }

    // MARK: - Interruption handling

    private func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            wasPlayingBeforeInterruption = isPlaying
            stopProgressTimer()
            if isCrossfading {
                crossfadeTimer?.invalidate()
                crossfadeTimer = nil
                nextPlayer?.pause()
            }
            DispatchQueue.main.async {
                self.isPlaying = false
                self.isPaused = true
            }

        case .ended:
            guard wasPlayingBeforeInterruption else { return }
            let options = (info[AVAudioSessionInterruptionOptionKey] as? UInt).map {
                AVAudioSession.InterruptionOptions(rawValue: $0)
            } ?? []
            guard options.contains(.shouldResume) else { return }
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                player?.play()
                if isCrossfading, let player, let nextPlayer {
                    let remaining = max(player.duration - player.currentTime, 0.01)
                    player.setVolume(0.0, fadeDuration: remaining)
                    nextPlayer.play()
                    nextPlayer.setVolume(1.0, fadeDuration: remaining)
                    crossfadeTimer = Timer.scheduledTimer(withTimeInterval: remaining, repeats: false) { [weak self] _ in
                        self?.promoteNextPlayer()
                    }
                }
                DispatchQueue.main.async {
                    self.isPlaying = true
                    self.isPaused = false
                }
                startProgressTimer()
                self.updateNowPlayingRate(1)
            } catch {
                print("AudioService: failed to reactivate after interruption — \(error)")
            }

        @unknown default:
            break
        }
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // nextPlayer.stop() during promoteNextPlayer() would otherwise race
        // this delegate call for the outgoing player and end the session mid-loop.
        guard player === self.player else { return }
        DispatchQueue.main.async {
            self.isPlaying = false
            self.isPaused = false
            self.progress = 0
            self.stopProgressTimer()
            self.clearNowPlaying()
            self.onPlaybackFinished?()
        }
    }

    // MARK: - Progress

    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: AppConfig.audioProgressInterval, repeats: true) { [weak self] _ in
            guard let self, let player = self.player else { return }
            let duration = max(player.duration, 1)
            self.progress = player.currentTime / duration

            // Only fades the true end of a non-looping playthrough.
            if !self.isLooping && !self.isFadingOutNearEnd {
                let remaining = duration - player.currentTime
                if remaining <= AppConfig.audioEndFadeDuration && remaining > 0 {
                    player.setVolume(0.0, fadeDuration: remaining)
                    self.isFadingOutNearEnd = true
                }
            }

            // Crossfade into the next playthrough so the loop point is inaudible.
            if self.isLooping && self.willCrossfade && !self.isCrossfading {
                let remaining = duration - player.currentTime
                if remaining <= AppConfig.audioCrossfadeDuration && remaining > 0 {
                    self.beginCrossfade(remaining: remaining)
                }
            }

            self.updateNowPlayingElapsed()
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    // MARK: - Crossfade loop

    private func beginCrossfade(remaining: TimeInterval) {
        guard let currentTrackURL, let outgoing = player else { return }
        isCrossfading = true
        outgoing.setVolume(0.0, fadeDuration: remaining)

        do {
            let incoming = try AVAudioPlayer(contentsOf: currentTrackURL)
            incoming.delegate = self
            incoming.numberOfLoops = 0
            incoming.volume = 0.0
            incoming.play()
            incoming.setVolume(1.0, fadeDuration: remaining)
            nextPlayer = incoming
        } catch {
            print("AudioService: failed to prepare crossfade player — \(error)")
            isCrossfading = false
            return
        }

        crossfadeTimer?.invalidate()
        crossfadeTimer = Timer.scheduledTimer(withTimeInterval: remaining, repeats: false) { [weak self] _ in
            self?.promoteNextPlayer()
        }
    }

    private func promoteNextPlayer() {
        guard let promoted = nextPlayer else { return }
        // player.stop() does not trigger audioPlayerDidFinishPlaying, so this
        // doesn't race the delegate — the identity guard there is a second
        // line of defense for the pause/resume-during-crossfade timing.
        player?.stop()
        player = promoted
        nextPlayer = nil
        isCrossfading = false
        isFadingOutNearEnd = false
        crossfadeTimer = nil
        updateNowPlayingElapsed()
    }
}
