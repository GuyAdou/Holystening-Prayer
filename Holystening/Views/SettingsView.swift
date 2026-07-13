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
