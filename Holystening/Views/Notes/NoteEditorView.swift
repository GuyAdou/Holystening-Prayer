import SwiftUI

struct NoteEditorView: View {
    @Bindable var note: Note
    @FocusState private var titleFocused: Bool
    @FocusState private var bodyFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Title", text: $note.title, axis: .vertical)
                .font(.title.bold())
                .focused($titleFocused)
                .accessibilityIdentifier("note-title-field")
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .onChange(of: note.title) { _, _ in note.updatedAt = .now }

            Divider().padding(.horizontal, 20)

            TextEditor(text: $note.content)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .focused($bodyFocused)
                .accessibilityIdentifier("note-body-editor")
                .onChange(of: note.content) { _, _ in note.updatedAt = .now }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    titleFocused = false
                    bodyFocused = false
                }
                .accessibilityIdentifier("note-done-button")
            }
        }
        .onAppear {
            if note.title.isEmpty && note.content.isEmpty {
                bodyFocused = true
            }
        }
    }
}
