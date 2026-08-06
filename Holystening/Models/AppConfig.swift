import Foundation

enum AppConfig {

    // MARK: - Feature Flags
    /// Notes is fully implemented but archived (hidden from the UI) for now.
    /// Nothing is deleted — flip this back to true to re-enable it.
    static let notesFeatureEnabled: Bool = false

    // MARK: - Audio
    /// All available prayer audio tracks. Add new tracks by appending to this array.
    static let tracks: [PrayerTrack] = [
        PrayerTrack(name: "Harmony of Heaven", fileName: "Harmony-of-Heaven", fileExtension: "mp3"),
    ]

    /// Default track played when the app launches for the first time.
    static let defaultTrackIndex: Int = 0

    /// How often (in seconds) the audio progress bar updates.
    static let audioProgressInterval: TimeInterval = 0.5

    /// Duration in seconds to fade out audio when the user stops the session.
    static let audioFadeOutDuration: TimeInterval = 2.0

    /// Duration in seconds to fade in audio when a prayer session starts.
    static let audioFadeInDuration: TimeInterval = 35.0

    /// Starting volume for the fade-in — audible immediately so playback
    /// doesn't look stalled, but still noticeably softer than full volume.
    static let audioFadeInStartVolume: Float = 0.35

    /// Whether the track loops indefinitely by default.
    static let defaultLoopEnabled: Bool = false

    // MARK: - Focus
    /// Available Focus modes the user can choose from.
    static let focusModes: [String] = [
        "Do Not Disturb",
        "Sleep",
        "Personal",
        "Work",
        "Driving",
    ]

    /// Default Focus mode selected on first launch.
    static let defaultFocusMode: String = "Do Not Disturb"

    // MARK: - Idle / Ambient Mode
    /// Seconds of inactivity before the UI fades out during a session.
    static let idleTimeout: TimeInterval = 8

    /// Duration of the fade-in / fade-out animation for idle mode.
    static let idleFadeDuration: TimeInterval = 1.5

    /// Opacity of the dim overlay when in idle mode.
    static let idleDimOpacity: Double = 0.45

    /// After waking from idle, a tap anywhere on the background re-dims immediately.
    static let tapBackgroundToDimAfterWake: Bool = true

    // MARK: - Onboarding
    enum Onboarding {
        // Screen 1
        static let s1Headline  = "Welcome to Holystening"
        static let s1Body      = "The distraction-free prayer app"
        static let s1CTA       = "Continue"

        // Screen 2
        static let s2Headline  = "Block everything out."
        static let s2Body      = "To allow Holystening to silence all notifications, grant it access to a Focus mode to turn on while you pray: "
        static let s2CTAOpen   = "Open Settings"
        static let s2CTA       = "Done"
        static let s2Step1Desc = "Open the Settings app, then tap Focus."
        static let s2Step2Desc = "Tap any Focus you'd like to use"
        static let s2Step3Desc = "Tap Add Schedule."
        static let s2Step4Desc = "Tap App, then select Holystening."

        // Screen 3
        static let s3Headline  = "Congratulations."
        static let s3Body      = "You can start your first distraction free prayer with instrumental music"
        static let s3CTA       = "Start"

        // Fonts
        static let wordmarkSize:    CGFloat = 11
        static let headlineSize:    CGFloat = 30
        static let bodySize:        CGFloat = 17
        static let stepTitleSize:   CGFloat = 20
        static let stepChipSize:    CGFloat = 11.5
        static let stepNoteSize:    CGFloat = 15
        static let ctaSize:             CGFloat = 18
        static let featureRowTitleSize: CGFloat = 17
        static let featureRowBodySize:  CGFloat = 16
    }

    // MARK: - Animations
    /// Duration of the background gradient transition when a session starts/stops.
    static let backgroundTransitionDuration: TimeInterval = 0.0

    /// Duration of the pulsing ring animation on the play button.
    static let pulseRingDuration: TimeInterval = 1.4
}
