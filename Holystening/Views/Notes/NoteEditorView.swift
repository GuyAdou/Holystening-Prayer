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
            NoteTitleField(text: $note.title, isFocused: $titleFocused)
            Divider().padding(.horizontal, 20)
            NoteBodyEditor(text: $note.content, isFocused: $bodyFocused)
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
                NoteSaveButton(hasUnsavedChanges: hasUnsavedChanges, action: saveNote)
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
