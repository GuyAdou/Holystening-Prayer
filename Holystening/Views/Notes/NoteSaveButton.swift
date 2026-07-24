import SwiftUI

/// Save-state concern (gray/gold checkmark) kept separate from the text
/// editing views, so toggling this doesn't force NoteTitleField or
/// NoteBodyEditor to re-render either.
struct NoteSaveButton: View {
    let hasUnsavedChanges: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
        }
        .buttonStyle(.glassProminent)
        .tint(hasUnsavedChanges ? AppColors.gold : Color(uiColor: .systemGray3))
        .animation(.default, value: hasUnsavedChanges)
        .id(hasUnsavedChanges)
        .accessibilityIdentifier("note-done-button")
        .accessibilityValue(hasUnsavedChanges ? "unsaved" : "saved")
    }
}
