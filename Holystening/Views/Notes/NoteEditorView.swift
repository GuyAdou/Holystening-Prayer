import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @Bindable var note: Note
    @Environment(\.modelContext) private var modelContext
    @State private var hasUnsavedChanges = false
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

            Divider().padding(.horizontal, 20)

            TextEditor(text: $note.content)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .focused($bodyFocused)
                .accessibilityIdentifier("note-body-editor")
        }
        .onChange(of: titleFocused) { _, focused in
            if focused { hasUnsavedChanges = true }
        }
        .onChange(of: bodyFocused) { _, focused in
            if focused { hasUnsavedChanges = true }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: saveNote) {
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
        .onAppear {
            let isNewNote = note.title.isEmpty && note.content.isEmpty
            if isNewNote {
                bodyFocused = true
            }
        }
        .onDisappear {
            saveOrDiscard()
        }
    }

    private func saveNote() {
        titleFocused = false
        bodyFocused = false
        saveOrDiscard()
        hasUnsavedChanges = false
    }

    /// Deletes the note instead of saving it if the user leaves both title
    /// and body empty — an untouched new note should never be listed.
    private func saveOrDiscard() {
        if note.title.isEmpty && note.content.isEmpty {
            modelContext.delete(note)
        } else {
            note.updatedAt = .now
            try? modelContext.save()
        }
    }
}
