import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Note.updatedAt, order: .reverse) private var notes: [Note]

    @State private var path: [Note] = []

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if notes.isEmpty {
                    ContentUnavailableView(
                        "No Notes",
                        systemImage: "note.text",
                        description: Text("Tap + to write your first note")
                    )
                } else {
                    List {
                        ForEach(notes) { note in
                            NavigationLink(value: note) {
                                NoteRow(note: note)
                            }
                        }
                        .onDelete { offsets in
                            let toDelete = offsets.map { notes[$0] }
                            if let current = path.last,
                               toDelete.contains(where: { $0.persistentModelID == current.persistentModelID }) {
                                path.removeLast()
                            }
                            toDelete.forEach { modelContext.delete($0) }
                        }
                    }
                }
            }
            .navigationTitle("Notes")
            .navigationDestination(for: Note.self) { note in
                NoteEditorView(note: note)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton(identifier: "notes-close-button") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addNote) {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityIdentifier("notes-new-button")
                }
            }
        }
    }

    private func addNote() {
        let note = Note()
        modelContext.insert(note)
        path.append(note)
    }
}

private struct NoteRow: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.displayTitle)
                .font(.headline)
                .lineLimit(1)
            HStack(spacing: 8) {
                Text(note.formattedDate)
                if !note.preview.isEmpty {
                    Text(note.preview).lineLimit(1)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
