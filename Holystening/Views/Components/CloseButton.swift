import SwiftUI

/// Circular "X" dismiss button — the standard iOS 26 close affordance,
/// used in place of a text "Close" button. Keeps "Close" as the
/// accessibility label so VoiceOver and existing UI tests still work.
struct CloseButton: View {
    let identifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color(uiColor: .systemGray5)))
        }
        .accessibilityLabel("Close")
        .accessibilityIdentifier(identifier)
    }
}
