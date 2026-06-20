import SwiftUI
import SwiftData

@main
struct PrayerApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var vm = PrayerViewModel()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                HomeView()
                    .environmentObject(vm)
            } else {
                OnboardingContainerView()
            }
        }
        .modelContainer(for: [NoteFolder.self, Note.self])
    }
}
