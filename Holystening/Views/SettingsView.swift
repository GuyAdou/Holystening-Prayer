import SwiftUI

struct SettingsView: View {
    @Binding var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var showFixInterruptions = false

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
                    Text("Apple Focus")
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
