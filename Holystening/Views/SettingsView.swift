import SwiftUI

struct SettingsView: View {
    @Binding var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var showFixInterruptions = false

    private var sessionDurationIndex: Binding<Int> {
        Binding(
            get: { SessionDurationSteps.index(for: settings.sessionDuration) },
            set: { settings.sessionDuration = SessionDurationSteps.values[$0] }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                // Audio track picker
                Section {
                    ForEach(Array(AppSettings.availableTracks.enumerated()), id: \.offset) { index, track in
                        HStack {
                            Text(track.name)
                            Spacer()
                            if settings.selectedTrackIndex == index {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            settings.selectedTrackIndex = index
                        }
                    }
                } header: {
                    Text("Prayer Audio")
                }

                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(SessionDurationSteps.label(for: settings.sessionDuration))
                            .font(.title3.weight(.semibold))
                            .contentTransition(.numericText())
                            .animation(.default, value: settings.sessionDuration)
                            .accessibilityIdentifier("session-duration-label")

                        SteppedGlassSlider(
                            selection: sessionDurationIndex,
                            stepCount: SessionDurationSteps.values.count
                        )
                        .padding(.vertical, 6)
                        .accessibilityIdentifier("session-duration-slider")
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Prayer Duration")
                } footer: {
                    Text("How long your prayer session runs. The track loops smoothly to fill the time.")
                }

Section("Interruptions") {
                    Button {
                        showFixInterruptions = true
                    } label: {
                        Label("Fix interruptions", systemImage: "bell.slash.fill")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showFixInterruptions) {
                FixInterruptionsView()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

}
