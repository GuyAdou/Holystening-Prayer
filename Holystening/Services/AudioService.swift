import AVFoundation
import Combine
import MediaPlayer
import UIKit

class AudioService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var progress: Double = 0.0
    @Published var duration: Double = 0.0

    private var player: AVAudioPlayer?
    private var progressTimer: Timer?
    private var fadeTimer: Timer?
    private var wasPlayingBeforeInterruption = false
    private var currentTrackName: String = ""
    var onPlaybackFinished: (() -> Void)?
    var onStopRequested: (() -> Void)?

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
        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: track.fileExtension) else {
            print("AudioService: file not found — \(track.fileName).\(track.fileExtension)")
            return
        }
        currentTrackName = track.name
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
        player?.numberOfLoops = loop ? -1 : 0
        player?.play()
        isPlaying = true
        isPaused = false
        startProgressTimer()
        setupNowPlaying()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        isPaused = true
        stopProgressTimer()
        updateNowPlayingRate(0)
    }

    func resume() {
        player?.play()
        isPlaying = true
        isPaused = false
        startProgressTimer()
        updateNowPlayingRate(1)
    }

    func setLooping(_ loop: Bool) {
        player?.numberOfLoops = loop ? -1 : 0
    }

    func stop() {
        isPaused = false
        stopProgressTimer()
        clearNowPlaying()
        fadeOut()
    }

    private func fadeOut() {
        guard let player else { return }
        let steps: Double = 20
        let interval = AppConfig.audioFadeOutDuration / steps
        let volumeStep = player.volume / Float(steps)
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self, let player = self.player else { timer.invalidate(); return }
            if player.volume > volumeStep {
                player.volume -= volumeStep
            } else {
                player.stop()
                player.currentTime = 0
                player.volume = 1.0
                self.isPlaying = false
                self.progress = 0
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
            DispatchQueue.main.async { self.isPlaying = false }

        case .ended:
            guard wasPlayingBeforeInterruption else { return }
            let options = (info[AVAudioSessionInterruptionOptionKey] as? UInt).map {
                AVAudioSession.InterruptionOptions(rawValue: $0)
            } ?? []
            guard options.contains(.shouldResume) else { return }
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                player?.play()
                DispatchQueue.main.async { self.isPlaying = true }
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
            self.progress = player.currentTime / max(player.duration, 1)
            self.updateNowPlayingElapsed()
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}
