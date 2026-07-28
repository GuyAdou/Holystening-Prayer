import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Note.updatedAt, order: .reverse) private var notes: [Note]

    @State private var path: [Note] = []
    @State private var searchText = ""

    private var filteredNotes: [Note] {
        guard !searchText.isEmpty else { return notes }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if notes.isEmpty {
                    ContentUnavailableView(
                        "No Notes",
                        systemImage: "note.text",
                        description: Text("Tap + to write your first note")
                    )
                } else if filteredNotes.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredNotes) { note in
                            NavigationLink(value: note) {
                                NoteRow(note: note)
                            }
                        }
                        .onDelete { offsets in
                            let toDelete = offsets.map { filteredNotes[$0] }
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
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button(action: addNote) {
                        Image(systemName: "square.and.pencil")
                    }
                    .buttonStyle(.glass)
                    .accessibilityIdentifier("notes-new-button")
                }
            }
            .searchable(text: $searchText)
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
