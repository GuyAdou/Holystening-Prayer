import SwiftUI

/// Isolated from NoteBodyEditor so typing in the body doesn't force this
/// view to re-render (and vice versa) — see NoteEditorView.
struct NoteTitleField: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        TextField("Title", text: $text, axis: .vertical)
            .font(.title.bold())
            .focused(isFocused)
            .accessibilityIdentifier("note-title-field")
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }
}
