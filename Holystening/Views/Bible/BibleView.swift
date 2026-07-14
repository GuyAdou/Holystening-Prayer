import SwiftUI

struct BibleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var book: BibleBook = .genesis
    @State private var chapter = 1
    @State private var verses: [BibleLibrary.Verse] = []
    @State private var loadFailed = false
    @State private var showPicker = false

    var body: some View {
        NavigationStack {
            Group {
                if loadFailed {
                    ContentUnavailableView(
                        "Couldn't Load",
                        systemImage: "exclamationmark.triangle",
                        description: Text("This chapter couldn't be found.")
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Chapter \(chapter)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppColors.bibleGold)
                                .padding(.bottom, 24)

                            ForEach(verses) { verse in
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("\(verse.number)")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(AppColors.bibleGold)
                                        .frame(minWidth: 20, alignment: .trailing)

                                    Text(verse.text)
                                        .font(.system(size: 17, design: .serif))
                                        .foregroundStyle(.primary)
                                        .lineSpacing(6)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.bottom, 14)
                            }
                        }
                        .padding(24)

                        Text("King James Version")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 24)
                            .accessibilityIdentifier("bible-version-note")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton(identifier: "bible-close-button") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    Button {
                        showPicker = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("\(book.name) \(chapter)")
                                .font(.headline)
                                .fontDesign(.serif)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(.primary)
                    }
                    .accessibilityIdentifier("bible-picker-trigger")
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button {
                        goToPreviousChapter()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Chapter \(chapter - 1)")
                        }
                        .font(.subheadline.weight(.medium))
                    }
                    .disabled(isAtFirstChapter)
                    .accessibilityIdentifier("bible-prev-chapter")

                    Spacer()

                    Button {
                        goToNextChapter()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Chapter \(chapter + 1)")
                            Image(systemName: "chevron.right")
                        }
                        .font(.subheadline.weight(.medium))
                    }
                    .disabled(isAtLastChapter)
                    .accessibilityIdentifier("bible-next-chapter")
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(.bar)
            }
        }
        .sheet(isPresented: $showPicker) {
            BiblePickerView { selectedBook, selectedChapter in
                book = selectedBook
                chapter = selectedChapter
            }
        }
        .task(id: "\(book.fileName)-\(chapter)") {
            loadChapter()
        }
    }

    private var isAtFirstChapter: Bool {
        chapter <= 1 && book.fileName == BibleBook.all.first?.fileName
    }

    private var isAtLastChapter: Bool {
        chapter >= book.chapterCount && book.fileName == BibleBook.all.last?.fileName
    }

    private func goToPreviousChapter() {
        if chapter > 1 {
            chapter -= 1
        } else if let index = BibleBook.all.firstIndex(where: { $0.fileName == book.fileName }), index > 0 {
            book = BibleBook.all[index - 1]
            chapter = book.chapterCount
        }
    }

    private func goToNextChapter() {
        if chapter < book.chapterCount {
            chapter += 1
        } else if let index = BibleBook.all.firstIndex(where: { $0.fileName == book.fileName }),
                  index < BibleBook.all.count - 1 {
            book = BibleBook.all[index + 1]
            chapter = 1
        }
    }

    private func loadChapter() {
        do {
            verses = try BibleLibrary.shared.verses(for: book, chapter: chapter)
            loadFailed = verses.isEmpty
        } catch {
            loadFailed = true
        }
    }
}
