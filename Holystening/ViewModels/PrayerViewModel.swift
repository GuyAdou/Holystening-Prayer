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

    private var cancellables = Set<AnyCancellable>()

    init() {
        // audio is a plain property, not @Published — views observing only
        // `vm` (e.g. HomeView via @EnvironmentObject) never re-render when
        // audio's own @Published properties (isPaused/isPlaying/progress)
        // change unless we forward that notification ourselves.
        audio.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        audio.onPlaybackFinished = { [weak self] in
            self?.handlePlaybackFinished()
        }
        audio.onStopRequested = { [weak self] in
            self?.stopSession()
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

    func pauseSession() {
        audio.pause()
    }

    func resumeSession() {
        audio.resume()
    }

    func stopSession() {
        audio.stop()
        focus.disable()
        UIApplication.shared.isIdleTimerDisabled = false
        isSessionActive = false
    }

    func togglePlayPause() {
        if !isSessionActive {
            startSession()
        } else if audio.isPaused {
            resumeSession()
        } else {
            pauseSession()
        }
    }

    func toggleLoop() {
        isLooping.toggle()
        audio.setLooping(isLooping)
    }

    // MARK: - Private

    private func handlePlaybackFinished() {
        focus.disable()
        UIApplication.shared.isIdleTimerDisabled = false
        isSessionActive = false
    }
}
