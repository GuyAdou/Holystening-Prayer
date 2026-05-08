import SwiftUI

struct SettingsView: View {
    @Binding var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

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
                } footer: {
                    Text("Add MP3 files to the Xcode bundle and register them in AppSettings.availableTracks.")
                }

                // Focus mode picker
                Section {
                    ForEach(AppSettings.availableFocusModes, id: \.self) { mode in
                        HStack {
                            Image(systemName: iconForFocus(mode))
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            Text(mode)
                            Spacer()
                            if settings.selectedFocusName == mode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            settings.selectedFocusName = mode
                        }
                    }
                } header: {
                    Text("Focus Mode")
                } footer: {
                    Text("The selected Focus will activate when prayer begins and deactivate when it ends.\n\nTip: In Shortcuts, create an automation named \"Prayer Focus enable\" that turns on this Focus, so the app can trigger it silently.")
                }

                // How it works
                Section("Focus Setup") {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Open Settings → Focus → Do Not Disturb", systemImage: "1.circle.fill")
                        Label("Tap Apps → Add App → select this app", systemImage: "2.circle.fill")
                        Label("Tap Add Schedule → set your prayer time", systemImage: "3.circle.fill")
                        Label("iOS will silence notifications automatically", systemImage: "4.circle.fill")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)

                    Link(destination: URL(string: "App-prefs:FOCUS")!) {
                        Label("Open Focus Settings", systemImage: "arrow.up.right.square")
                    }
                }
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

    private func iconForFocus(_ mode: String) -> String {
        switch mode {
        case "Do Not Disturb": return "moon.fill"
        case "Sleep":           return "bed.double.fill"
        case "Personal":        return "person.fill"
        case "Work":            return "briefcase.fill"
        case "Driving":         return "car.fill"
        default:                return "moon.stars.fill"
        }
    }
}
