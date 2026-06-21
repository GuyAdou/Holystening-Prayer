import Foundation
import Combine
import AppIntents
import SwiftUI

class FocusService: ObservableObject {
    @Published var isFocusActive = false

    func enable(focusName: String) {
        DispatchQueue.main.async { self.isFocusActive = true }
    }

    func disable() {
        DispatchQueue.main.async { self.isFocusActive = false }
    }
}

// Registers this app with the iOS Focus system.
// Once registered, users can go to:
// Settings → Focus → Do Not Disturb → Apps → add this app
// iOS will then respect the Focus filter whenever that Focus is active.
struct PrayerFocusFilter: SetFocusFilterIntent {
    static var title: LocalizedStringResource = "Prayer App Focus Filter"

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "Prayer App Focus Filter")
    }

    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(true, forKey: "focusConnected")
        return .result()
    }
}
