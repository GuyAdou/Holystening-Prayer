//
//  HstningTests.swift
//  HstningTests
//
//  Created by Guy-Georges Adou Bogolo on 4/2/26.
//

import Combine
import Foundation
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

    // MARK: - Duration label available before the first session

    // The duration label reads vm.audio.duration, which was previously only
    // populated by audio.load(track:) inside startSession() — so it showed
    // "0:00" until the user tapped play once. init() must preload it.
    @Test func durationIsAvailableBeforeSessionStarts() async throws {
        let vm = PrayerViewModel()

        #expect(vm.isSessionActive == false)
        #expect(vm.audio.duration > 0)
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

    // MARK: - Session duration wiring (Settings slider -> AudioService)

    @Test func defaultSessionDurationIsFiveMinutes() async throws {
        let vm = PrayerViewModel()
        #expect(vm.settings.sessionDuration == SessionDurationSteps.defaultDuration)
    }

    @Test func startSession_setsAudioSessionTargetFromSettings() async throws {
        let vm = PrayerViewModel()
        vm.settings.sessionDuration = 600

        vm.startSession()

        #expect(vm.audio.sessionRemaining == 600)
        #expect(vm.audio.sessionProgress == 0)
    }

    @Test func formattedSessionRemaining_matchesSelectedDuration() async throws {
        let vm = PrayerViewModel()
        vm.settings.sessionDuration = 300

        vm.startSession()

        #expect(vm.audio.formattedSessionRemaining == "5:00")
    }
}

// MARK: - SessionDurationSteps

struct SessionDurationStepsTests {

    @Test func valuesSpanFiveMinutesToOneHourInFiveMinuteSteps() {
        let values = SessionDurationSteps.values
        #expect(values.first == 300)
        #expect(values.last == 3600)
        #expect(values.count == 12)
        #expect(values == values.sorted())
    }

    @Test func defaultDurationIsTheFirstStep() {
        #expect(SessionDurationSteps.defaultDuration == 300)
    }

    @Test(arguments: [
        (300.0, "5 min"),
        (600.0, "10 min"),
        (1800.0, "30 min"),
        (3600.0, "1 hr"),
    ])
    func labelFormatsMinutesOrHour(duration: TimeInterval, expected: String) {
        #expect(SessionDurationSteps.label(for: duration) == expected)
    }

    @Test func indexRoundTripsForEveryStep() {
        for (i, value) in SessionDurationSteps.values.enumerated() {
            #expect(SessionDurationSteps.index(for: value) == i)
        }
    }

    @Test func indexFallsBackToZeroForAnUnknownValue() {
        #expect(SessionDurationSteps.index(for: 42) == 0)
    }
}
