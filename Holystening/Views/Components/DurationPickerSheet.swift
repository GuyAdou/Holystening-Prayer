import SwiftUI

/// Duration picker presented as a bottom sheet from the Home screen — the
/// only place prayer duration is set now that Settings no longer has its
/// own slider. Edits are local until "Confirm" commits them to `settings`;
/// swiping the sheet away discards the change.
struct DurationPickerSheet: View {
    @Binding var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @State private var pendingIndex: Int

    init(settings: Binding<AppSettings>) {
        self._settings = settings
        self._pendingIndex = State(initialValue: SessionDurationSteps.index(for: settings.wrappedValue.sessionDuration))
    }

    var body: some View {
        VStack(spacing: 18) {
            Text("Choose a length")
                .font(.title3.weight(.semibold))
                .padding(.top, 8)

            Text(SessionDurationSteps.label(for: SessionDurationSteps.values[pendingIndex]))
                .font(.system(size: 30, weight: .semibold))
                .contentTransition(.numericText())
                .animation(.default, value: pendingIndex)

            SteppedGlassSlider(
                selection: $pendingIndex,
                stepCount: SessionDurationSteps.values.count
            )
            .padding(.horizontal, 32)
            .accessibilityIdentifier("duration-sheet-slider")

            Button("Confirm") {
                settings.sessionDuration = SessionDurationSteps.values[pendingIndex]
                dismiss()
            }
            .buttonStyle(.glassProminent)
            .accessibilityIdentifier("duration-sheet-confirm-button")
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
        .presentationDetents([.fraction(0.36)])
        .presentationDragIndicator(.visible)
    }
}
