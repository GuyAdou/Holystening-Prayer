//
//  HstningTests.swift
//  HstningTests
//
//  Created by Guy-Georges Adou Bogolo on 4/2/26.
//

import Combine
import Testing
@testable import Holystening

@MainActor
struct PrayerViewModelTests {

    // MARK: - Regression: AudioService state must reach views observing only PrayerViewModel

    // HomeView observes `vm` via @EnvironmentObject only — it never observes
    // `vm.audio` directly. AudioService's own @Published properties
    // (isPaused, isPlaying, progress) must be forwarded through
    // vm.objectWillChange, or the play/pause icon and progress bar silently
    // stop updating even though playback state is actually changing.
    @Test func audioIsPausedChangePropagatesToViewModel() async throws {
        let vm = PrayerViewModel()
        var changeCount = 0
        let cancellable = vm.objectWillChange.sink { _ in changeCount += 1 }

        vm.audio.isPaused = true

        #expect(changeCount > 0)
        withExtendedLifetime(cancellable) {}
    }

    @Test func audioIsPlayingChangePropagatesToViewModel() async throws {
        let vm = PrayerViewModel()
        var changeCount = 0
        let cancellable = vm.objectWillChange.sink { _ in changeCount += 1 }

        vm.audio.isPlaying = true

        #expect(changeCount > 0)
        withExtendedLifetime(cancellable) {}
    }

    @Test func audioProgressChangePropagatesToViewModel() async throws {
        let vm = PrayerViewModel()
        var changeCount = 0
        let cancellable = vm.objectWillChange.sink { _ in changeCount += 1 }

        vm.audio.progress = 0.5

        #expect(changeCount > 0)
        withExtendedLifetime(cancellable) {}
    }

    // MARK: - togglePlayPause() dispatch

    @Test func togglePlayPause_whenSessionInactive_startsSession() async throws {
        let vm = PrayerViewModel()
        #expect(vm.isSessionActive == false)

        vm.togglePlayPause()

        #expect(vm.isSessionActive == true)
    }

    @Test func togglePlayPause_whenPlaying_pauses() async throws {
        let vm = PrayerViewModel()
        vm.isSessionActive = true
        vm.audio.isPaused = false

        vm.togglePlayPause()

        #expect(vm.audio.isPaused == true)
        #expect(vm.audio.isPlaying == false)
    }

    @Test func togglePlayPause_whenPaused_resumes() async throws {
        let vm = PrayerViewModel()
        vm.isSessionActive = true
        vm.audio.isPaused = true

        vm.togglePlayPause()

        #expect(vm.audio.isPaused == false)
        #expect(vm.audio.isPlaying == true)
    }

    // MARK: - Direct pause/resume session calls stay in sync with AudioService

    @Test func pauseSession_setsAudioIsPaused() async throws {
        let vm = PrayerViewModel()

        vm.pauseSession()

        #expect(vm.audio.isPaused == true)
    }

    @Test func resumeSession_clearsAudioIsPaused() async throws {
        let vm = PrayerViewModel()
        vm.pauseSession()
        #expect(vm.audio.isPaused == true)

        vm.resumeSession()

        #expect(vm.audio.isPaused == false)
    }
}
