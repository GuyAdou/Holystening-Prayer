import SwiftUI

struct BiblePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (BibleBook, Int) -> Void

    @State private var selectedBook: BibleBook?

    var body: some View {
        NavigationStack {
            Group {
                if let selectedBook {
                    chapterGrid(for: selectedBook)
                } else {
                    bookList
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(selectedBook?.name ?? "Books")
                        .font(.headline)
                        .fontDesign(.serif)
                }
                if selectedBook != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Books") { self.selectedBook = nil }
                            .accessibilityIdentifier("bible-picker-back-to-books")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CloseButton(identifier: "bible-picker-close-button") { dismiss() }
                }
            }
        }
    }

    private var bookList: some View {
        List {
            Section("Old Testament") {
                ForEach(BibleBook.all.filter { $0.testament == .old }) { book in
                    bookRow(book)
                }
            }
            Section("New Testament") {
                ForEach(BibleBook.all.filter { $0.testament == .new }) { book in
                    bookRow(book)
                }
            }
        }
        .accessibilityIdentifier("bible-book-list")
    }

    private func bookRow(_ book: BibleBook) -> some View {
        Button {
            selectedBook = book
        } label: {
            HStack {
                Text(book.name)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .accessibilityIdentifier("bible-book-\(book.fileName)")
    }

    private func chapterGrid(for book: BibleBook) -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                ForEach(1...book.chapterCount, id: \.self) { chapterNumber in
                    Button {
                        onSelect(book, chapterNumber)
                        dismiss()
                    } label: {
                        Text("\(chapterNumber)")
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color(uiColor: .systemGray6)))
                            .foregroundStyle(.primary)
                    }
                    .accessibilityIdentifier("bible-chapter-\(chapterNumber)")
                }
            }
            .padding()
        }
    }
}
