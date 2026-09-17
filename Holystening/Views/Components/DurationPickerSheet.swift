import SwiftUI

/// Duration picker presented as a bottom sheet from the Home screen — the
/// only place prayer duration is set now that Settings no longer has its
/// own slider. Edits are local until "Confirm" commits them to `settings`;
/// swiping the sheet away discards the change. "Set as default" is
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

    /// Always exactly one default, so turning this off (without picking
    /// another duration as the default) is a no-op — the switch springs
    /// back to on.
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

    private var selected: (value: String, unit: String) {
        SessionDurationSteps.components(for: SessionDurationSteps.values[pendingIndex])
    }

    var body: some View {
        VStack(spacing: 22) {
            Text("Session Length")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.top, 8)

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(selected.value)
                    .font(.system(size: 64, weight: .bold))
                    .contentTransition(.numericText())
                Text(selected.unit)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .foregroundStyle(.white)
            .animation(.default, value: pendingIndex)

            VStack(spacing: 8) {
                SteppedGlassSlider(
                    selection: $pendingIndex,
                    stepCount: SessionDurationSteps.values.count,
                    tint: .white,
                    showsTicks: false
                )
                .accessibilityIdentifier("duration-sheet-slider")

                HStack {
                    Text("\(Int(SessionDurationSteps.values.first! / 60)) min")
                    Spacer()
                    Text("\(Int(SessionDurationSteps.values.last! / 60)) min")
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 32)

            Toggle(isOn: isDefaultTimerOn) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Set as default")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white)
                    Text("Used for new sessions")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .tint(.green)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .accessibilityIdentifier("duration-sheet-default-toggle")

            Button {
                settings.sessionDuration = SessionDurationSteps.values[pendingIndex]
                dismiss()
            } label: {
                Text("Confirm")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.roundedRectangle(radius: 20))
            .tint(.blue)
            .accessibilityIdentifier("duration-sheet-confirm-button")
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .presentationDetents([.height(460)])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppColors.sessionBackground)
        .presentationCornerRadius(32)
    }
}
