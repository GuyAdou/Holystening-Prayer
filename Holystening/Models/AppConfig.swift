import Foundation

enum AppConfig {

    // MARK: - Audio
    /// All available prayer audio tracks. Add new tracks by appending to this array.
    static let tracks: [PrayerTrack] = [
        PrayerTrack(name: "Instrumental Prayer", fileName: "Instrumental-music-1", fileExtension: "mp3"),
    ]

    /// Default track played when the app launches for the first time.
    static let defaultTrackIndex: Int = 0

    /// How often (in seconds) the audio progress bar updates.
    static let audioProgressInterval: TimeInterval = 0.5

    /// Duration in seconds to fade out audio when the user stops the session.
    static let audioFadeOutDuration: TimeInterval = 2.0

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

    // MARK: - Animations
    /// Duration of the background gradient transition when a session starts/stops.
    static let backgroundTransitionDuration: TimeInterval = 1.0

    /// Duration of the pulsing ring animation on the play button.
    static let pulseRingDuration: TimeInterval = 1.4
}
