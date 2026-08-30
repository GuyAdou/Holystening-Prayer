import Foundation

/// The selectable prayer-session lengths (5-minute steps, 5 min–1 hr) and
/// how to label them. Kept separate from SteppedGlassSlider — which knows
/// nothing about time — so future stepped sliders (fade length, volume,
/// a saved "default" vs. a one-off override for this session) can reuse
/// the same component with an entirely different step set.
enum SessionDurationSteps {
    static let values: [TimeInterval] = stride(from: 5, through: 60, by: 5).map { TimeInterval($0 * 60) }
    static let defaultDuration: TimeInterval = values.first ?? 300

    static func label(for duration: TimeInterval) -> String {
        let minutes = Int((duration / 60).rounded())
        return minutes >= 60 ? "1 hr" : "\(minutes) min"
    }

    static func index(for duration: TimeInterval) -> Int {
        values.firstIndex(of: duration) ?? 0
    }
}
