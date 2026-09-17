import Foundation

/// The selectable prayer-session lengths (5-minute steps, 5 min–1 hr) and
/// how to label them. Kept separate from SteppedGlassSlider — which knows
/// nothing about time — so future stepped sliders (fade length, volume,
/// a saved "default" vs. a one-off override for this session) can reuse
/// the same component with an entirely different step set.
enum SessionDurationSteps {
    static let values: [TimeInterval] = stride(from: 5, through: 60, by: 5).map { TimeInterval($0 * 60) }
    static let defaultDuration: TimeInterval = values.first ?? 300

    private static let savedDefaultDurationKey = "savedDefaultSessionDuration"

    /// The duration the user has marked as the app's default via the
    /// duration picker's "Default timer" control. Persists across launches
    /// and sessions until they mark a different duration as the default;
    /// falls back to `defaultDuration` until they ever do.
    static var savedDefaultDuration: TimeInterval {
        get {
            let stored = UserDefaults.standard.double(forKey: savedDefaultDurationKey)
            return stored > 0 ? stored : defaultDuration
        }
        set { UserDefaults.standard.set(newValue, forKey: savedDefaultDurationKey) }
    }

    static func label(for duration: TimeInterval) -> String {
        let minutes = Int((duration / 60).rounded())
        return minutes >= 60 ? "1 hr" : "\(minutes) min"
    }

    static func index(for duration: TimeInterval) -> Int {
        values.firstIndex(of: duration) ?? 0
    }
}
