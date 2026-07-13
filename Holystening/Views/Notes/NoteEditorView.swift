import SwiftUI
import SwiftData
import PencilKit

struct NoteEditorView: View {
    @Bindable var note: Note
    @Environment(\.modelContext) private var modelContext
    @State private var showDrawing = false
    @State private var drawing = PKDrawing()
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
                .onChange(of: note.title) { _, _ in
                    note.updatedAt = .now
                    hasUnsavedChanges = true
                }

            Divider().padding(.horizontal, 20)

            if showDrawing {
                DrawingCanvas(drawing: $drawing)
                    .ignoresSafeArea(edges: .bottom)
                    .onChange(of: drawing) { _, new in
                        note.drawingData = new.dataRepresentation()
                        note.updatedAt = .now
                        hasUnsavedChanges = true
                    }
            } else {
                TextEditor(text: $note.content)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .focused($bodyFocused)
                    .accessibilityIdentifier("note-body-editor")
                    .onChange(of: note.content) { _, _ in
                        note.updatedAt = .now
                        hasUnsavedChanges = true
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if hasUnsavedChanges {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: saveNote) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(AppColors.gold))
                    }
                    .accessibilityIdentifier("note-done-button")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showDrawing.toggle()
                } label: {
                    Image(systemName: showDrawing ? "text.alignleft" : "pencil.tip")
                }
            }
        }
        .onAppear {
            if let data = note.drawingData, let saved = try? PKDrawing(data: data) {
                drawing = saved
            }
            let isNewNote = note.title.isEmpty && note.content.isEmpty && note.drawingData == nil
            if isNewNote {
                bodyFocused = true
                hasUnsavedChanges = true
            }
        }
    }

    private func saveNote() {
        titleFocused = false
        bodyFocused = false
        try? modelContext.save()
        hasUnsavedChanges = false
    }
}
