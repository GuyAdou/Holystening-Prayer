import SwiftUI
import SwiftData

@main
struct PrayerApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingContainerView()
            }
        }
        .modelContainer(for: [NoteFolder.self, Note.self])
    }
}
