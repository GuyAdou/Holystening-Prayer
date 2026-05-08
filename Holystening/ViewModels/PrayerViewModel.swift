import Foundation
import Combine
import UIKit

@MainActor
class PrayerViewModel: ObservableObject {
    @Published var isSessionActive = false
    @Published var settings = AppSettings()
    @Published var isLooping: Bool = AppConfig.defaultLoopEnabled

    let audio = AudioService()
    let focus = FocusService()

    init() {
        audio.onPlaybackFinished = { [weak self] in
            self?.handlePlaybackFinished()
        }
    }

    var currentTrack: PrayerTrack {
        let tracks = AppSettings.availableTracks
        let index = min(settings.selectedTrackIndex, tracks.count - 1)
        return tracks[index]
    }

    // MARK: - Actions

    func startSession() {
        audio.load(track: currentTrack)
        audio.play(loop: isLooping)
        focus.enable(focusName: settings.selectedFocusName)
        UIApplication.shared.isIdleTimerDisabled = true
        isSessionActive = true
    }

    func toggleLoop() {
        isLooping.toggle()
        audio.setLooping(isLooping)
    }

    func stopSession() {
        audio.stop()
        focus.disable()
        UIApplication.shared.isIdleTimerDisabled = false
        isSessionActive = false
    }

    func toggleSession() {
        if isSessionActive {
            stopSession()
        } else {
            startSession()
        }
    }

    // MARK: - Private

    private func handlePlaybackFinished() {
        focus.disable()
        isSessionActive = false
    }
}
