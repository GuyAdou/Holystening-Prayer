import SwiftUI

/// "X" dismiss button — same plain toolbar-icon-button style as the
/// "New Note" button, used in place of a text "Close" button. Keeps
/// "Close" as the accessibility label so VoiceOver and existing UI
/// tests still work.
struct CloseButton: View {
    let identifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
        }
        .accessibilityLabel("Close")
        .accessibilityIdentifier(identifier)
    }
}
