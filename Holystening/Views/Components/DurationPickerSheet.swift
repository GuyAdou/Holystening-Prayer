import SwiftUI

/// Duration picker presented as a bottom sheet from the Home screen — the
/// only place prayer duration is set now that Settings no longer has its
/// own slider. Edits are local until "Confirm" commits them to `settings`;
/// swiping the sheet away discards the change. "Default timer" is
/// independent of that — it writes straight to SessionDurationSteps
/// .savedDefaultDuration immediately, since it governs what future
/// launches start at, not this session's pick.
struct DurationPickerSheet: View {
    @Binding var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @State private var pendingIndex: Int
    @State private var defaultDuration: TimeInterval

    init(settings: Binding<AppSettings>) {
        self._settings = settings
        self._pendingIndex = State(initialValue: SessionDurationSteps.index(for: settings.wrappedValue.sessionDuration))
        self._defaultDuration = State(initialValue: SessionDurationSteps.savedDefaultDuration)
    }

    /// Radio semantics, not a switch — turning it on marks the currently
    /// selected duration as the default; there's always exactly one
    /// default, so turning it off (without picking another) is a no-op.
    private var isDefaultTimerOn: Binding<Bool> {
        Binding(
            get: { SessionDurationSteps.values[pendingIndex] == defaultDuration },
            set: { isOn in
                guard isOn else { return }
                let duration = SessionDurationSteps.values[pendingIndex]
                defaultDuration = duration
                SessionDurationSteps.savedDefaultDuration = duration
            }
        )
    }

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 6) {
                Text("Choose a length")
                    .font(.title3.weight(.semibold))

                Text(SessionDurationSteps.label(for: SessionDurationSteps.values[pendingIndex]))
                    .font(.system(size: 32, weight: .bold))
                    .contentTransition(.numericText())
                    .animation(.default, value: pendingIndex)
            }
            .padding(.top, 8)

            SteppedGlassSlider(
                selection: $pendingIndex,
                stepCount: SessionDurationSteps.values.count
            )
            .padding(.horizontal, 32)
            .accessibilityIdentifier("duration-sheet-slider")

            Toggle("Default timer", isOn: isDefaultTimerOn)
                .toggleStyle(.radio)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(uiColor: .systemGray6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .accessibilityIdentifier("duration-sheet-default-toggle")

            Button("Confirm") {
                settings.sessionDuration = SessionDurationSteps.values[pendingIndex]
                dismiss()
            }
            .buttonStyle(.glassProminent)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier("duration-sheet-confirm-button")
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .presentationDetents([.height(360)])
        .presentationDragIndicator(.visible)
    }
}

private struct RadioToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn = true
        } label: {
            HStack {
                configuration.label
                    .font(.subheadline)
                Spacer()
                Image(systemName: configuration.isOn ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(configuration.isOn ? AppColors.teal : Color.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

private extension ToggleStyle where Self == RadioToggleStyle {
    static var radio: RadioToggleStyle { RadioToggleStyle() }
}
