import Foundation

enum BibleLibraryError: Error {
    case resourceMissing
    case chapterNotFound
}

/// Loads KJV text bundled in the app (Resources/KJV/*.json) — no network calls.
final class BibleLibrary {
    static let shared = BibleLibrary()

    struct Verse: Identifiable {
        var id: Int { number }
        let number: Int
        let text: String
    }

    private struct BookFile: Decodable {
        let book: String
        let chapters: [ChapterFile]
    }

    private struct ChapterFile: Decodable {
        let chapter: String
        let verses: [VerseFile]
    }

    private struct VerseFile: Decodable {
        let verse: String
        let text: String
    }

    private var cache: [String: BookFile] = [:]

    func verses(for book: BibleBook, chapter: Int) throws -> [Verse] {
        let bookFile = try loadBookFile(book)
        guard let chapterFile = bookFile.chapters.first(where: { Int($0.chapter) == chapter }) else {
            throw BibleLibraryError.chapterNotFound
        }
        return chapterFile.verses.compactMap { verse in
            guard let number = Int(verse.verse) else { return nil }
            return Verse(number: number, text: verse.text.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }

    private func loadBookFile(_ book: BibleBook) throws -> BookFile {
        if let cached = cache[book.fileName] { return cached }
        guard let url = Bundle.main.url(forResource: book.fileName, withExtension: "json") else {
            throw BibleLibraryError.resourceMissing
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(BookFile.self, from: data)
        cache[book.fileName] = decoded
        return decoded
    }
}
