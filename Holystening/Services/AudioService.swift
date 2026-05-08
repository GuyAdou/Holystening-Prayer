import AVFoundation
import Combine

class AudioService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var progress: Double = 0.0
    @Published var duration: Double = 0.0

    private var player: AVAudioPlayer?
    private var progressTimer: Timer?
    private var fadeTimer: Timer?
    private var wasPlayingBeforeInterruption = false
    var onPlaybackFinished: (() -> Void)?

    override init() {
        super.init()
        configureAudioSession()
        setupInterruptionObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: []
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioService: failed to configure session — \(error)")
        }
    }

    func load(track: PrayerTrack) {
        guard let url = Bundle.main.url(
            forResource: track.fileName,
            withExtension: track.fileExtension
        ) else {
            print("AudioService: file not found — \(track.fileName).\(track.fileExtension)")
            return
        }

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
        startProgressTimer()
    }

    func setLooping(_ loop: Bool) {
        player?.numberOfLoops = loop ? -1 : 0
    }

    func stop() {
        stopProgressTimer()
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
            self.progress = 0
            self.stopProgressTimer()
            self.onPlaybackFinished?()
        }
    }

    // MARK: - Progress

    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: AppConfig.audioProgressInterval, repeats: true) { [weak self] _ in
            guard let self, let player = self.player else { return }
            self.progress = player.currentTime / max(player.duration, 1)
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}
