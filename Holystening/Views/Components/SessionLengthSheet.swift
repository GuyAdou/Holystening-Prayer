import SwiftUI

/// "Session Length" sheet — presented from the Home screen to choose how
/// long a prayer session runs (design handoff: Session Length Sheet).
/// Edits are local until "Confirm" commits them to `settings`; swiping the
/// sheet away discards the change. "Set as default" is independent of
/// that — it writes straight to SessionDurationSteps.savedDefaultDuration
/// immediately, since it governs what future launches start at, not this
/// session's pick.
///
/// The default radio always reflects "does the slider sit on the saved
/// default" and reassigns it on tap — it does not clear to "no default"
/// (there's no such state; SessionDurationSteps.savedDefaultDuration
/// always falls back to 5 min). The handoff spec describes a nil-able
/// default; kept the existing, already-shipped behavior instead since it's
/// covered by DurationSheet UI tests — flagged for the user to confirm.
struct SessionLengthSheet: View {
    @Binding var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme

    var range: ClosedRange<Int> = 5...60
    var step: Int = 5

    @State private var minutes: Int
    @State private var defaultDuration: TimeInterval

    init(settings: Binding<AppSettings>) {
        self._settings = settings
        self._minutes = State(initialValue: Int(settings.wrappedValue.sessionDuration / 60))
        self._defaultDuration = State(initialValue: SessionDurationSteps.savedDefaultDuration)
    }

    private var isDefault: Bool { TimeInterval(minutes * 60) == defaultDuration }

    private var isDefaultTimerOn: Binding<Bool> {
        Binding(
            get: { isDefault },
            set: { isOn in
                guard isOn else { return }
                let duration = TimeInterval(minutes * 60)
                defaultDuration = duration
                SessionDurationSteps.savedDefaultDuration = duration
            }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Session Length")
                .font(.headline)
                .padding(.top, 26)
                .padding(.bottom, 18)

            HStack(alignment: .firstTextBaseline, spacing: 7) {
                Text("\(minutes)")
                    .font(.system(size: 72, weight: .light))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text("min")
                    .font(.system(size: 21))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
            .accessibilityElement(children: .combine)

            VStack(spacing: 4) {
                MinuteSteppedSlider(value: $minutes, range: range, step: step)
                    .frame(height: 36)
                    .accessibilityIdentifier("duration-sheet-slider")

                HStack {
                    Text("\(range.lowerBound) min")
                    Spacer()
                    Text("\(range.upperBound) min")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 2)
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)

            Toggle("Set as default", isOn: isDefaultTimerOn)
                .toggleStyle(.sessionDefaultRadio)
                .accessibilityIdentifier("duration-sheet-default-toggle")
                .padding(.horizontal, 16)
                .padding(.top, 18)

            // Absorbs whatever's left of the system-provided sheet height
            // so Confirm always sits near the bottom with a fixed margin,
            // regardless of exact detent size on a given device.
            Spacer(minLength: 12)

            Button {
                settings.sessionDuration = TimeInterval(minutes * 60)
                dismiss()
            } label: {
                Text("Confirm")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.capsule)
            .tint(.blue)
            .accessibilityIdentifier("duration-sheet-confirm-button")
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 5)
        }
        .sensoryFeedback(.selection, trigger: minutes)
        // .fraction is the relative-height knob — a % of screen height that
        // scales per device, unlike .height(_:) which is a fixed point
        // value. .medium is just Apple's preset ~0.5; tune this number
        // directly to make the card taller/shorter.
        .presentationDetents([.fraction(0.5)])
        .presentationDragIndicator(.visible)
    }
}

/// "Set as default" row style — radio on the left, title + subtitle text,
/// token-matched row fill. A `Toggle` (not a plain button) so it keeps the
/// switch accessibility role existing tests rely on.
private struct SessionDefaultRadioToggleStyle: ToggleStyle {
    @Environment(\.colorScheme) private var scheme

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn = true
        } label: {
            HStack(spacing: 14) {
                RadioDot(isOn: configuration.isOn)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Set as default")
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text("Used for new sessions")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .frame(minHeight: 44)
            .background(rowFill, in: .rect(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(configuration.isOn ? .isSelected : [])
    }

    private var rowFill: Color {
        scheme == .dark ? .white.opacity(0.08) : Color(white: 0.47).opacity(0.10)
    }
}

private extension ToggleStyle where Self == SessionDefaultRadioToggleStyle {
    static var sessionDefaultRadio: SessionDefaultRadioToggleStyle { SessionDefaultRadioToggleStyle() }
}

private struct RadioDot: View {
    let isOn: Bool

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(isOn ? Color.blue : Color.secondary, lineWidth: 1.5)
                .background(Circle().fill(isOn ? Color.blue : .clear))
            Circle()
                .fill(.white)
                .frame(width: 9, height: 9)
                .scaleEffect(isOn ? 1 : 0)
        }
        .frame(width: 24, height: 24)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isOn)
    }
}

/// Discrete minute slider for the Session Length sheet — a plain white
/// knob with a drop shadow and dots only between the two ends, matching
/// this design's own spec. Visually distinct from the app's general
/// SteppedGlassSlider (glass thumb, dot per step including the ends),
/// which stays as-is for any other stepped control.
private struct MinuteSteppedSlider: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let span = Double(range.upperBound - range.lowerBound)
            let frac = Double(value - range.lowerBound) / span
            let inset: CGFloat = 5 // dots stay clear of the rounded caps

            ZStack(alignment: .leading) {
                Capsule().fill(trackColor).frame(height: 10)
                Capsule().fill(fillColor).frame(width: max(10, w * frac), height: 10)

                ForEach(Array(stride(from: range.lowerBound + step, to: range.upperBound, by: step)), id: \.self) { v in
                    let p = Double(v - range.lowerBound) / span
                    Circle()
                        .fill(v <= value ? dotOn : dotOff)
                        .frame(width: 4, height: 4)
                        .position(x: inset + (w - inset * 2) * p, y: geo.size.height / 2)
                }

                Circle()
                    .fill(.white)
                    .frame(width: 30, height: 30)
                    .shadow(color: .black.opacity(0.22), radius: 7, y: 4)
                    .position(x: w * frac, y: geo.size.height / 2)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { g in
                let f = min(1, max(0, g.location.x / w))
                let raw = Double(range.lowerBound) + f * span
                value = Int((raw / Double(step)).rounded()) * step
            })
        }
        .accessibilityElement()
        .accessibilityLabel("Session length")
        .accessibilityValue("\(value) minutes")
        .accessibilityAdjustableAction { dir in
            switch dir {
            case .increment: value = min(range.upperBound, value + step)
            case .decrement: value = max(range.lowerBound, value - step)
            @unknown default: break
            }
        }
    }

    private var dark: Bool { scheme == .dark }
    private var trackColor: Color { dark ? .white.opacity(0.14) : Color(white: 0.47).opacity(0.16) }
    private var fillColor: Color { dark ? .white : .blue }
    private var dotOn: Color { dark ? .black.opacity(0.28) : .white.opacity(0.6) }
    private var dotOff: Color { dark ? .white.opacity(0.35) : Color(red: 60 / 255, green: 60 / 255, blue: 67 / 255).opacity(0.28) }
}
