import SwiftUI

/// Isolated from NoteTitleField so typing in the title doesn't force this
/// view to re-render (and vice versa) — see NoteEditorView.
struct NoteBodyEditor: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        TextEditor(text: $text)
            .font(.body)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .focused(isFocused)
            .accessibilityIdentifier("note-body-editor")
    }
}
