import SwiftUI
import PencilKit

struct NoteEditorView: View {
    @Bindable var note: Note
    @State private var showDrawing = false
    @State private var drawing = PKDrawing()
    @FocusState private var titleFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Title", text: $note.title, axis: .vertical)
                .font(.title.bold())
                .focused($titleFocused)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .onChange(of: note.title) { _, _ in note.updatedAt = .now }

            Divider().padding(.horizontal, 20)

            if showDrawing {
                DrawingCanvas(drawing: $drawing)
                    .ignoresSafeArea(edges: .bottom)
                    .onChange(of: drawing) { _, new in
                        note.drawingData = new.dataRepresentation()
                        note.updatedAt = .now
                    }
            } else {
                TextEditor(text: $note.content)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .onChange(of: note.content) { _, _ in note.updatedAt = .now }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
            if note.title.isEmpty { titleFocused = true }
        }
    }
}
