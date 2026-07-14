import Foundation

struct BibleBook: Identifiable, Hashable {
    enum Testament: String {
        case old = "Old Testament"
        case new = "New Testament"
    }

    var id: String { name }
    let name: String
    let fileName: String
    let chapterCount: Int
    let testament: Testament
}

extension BibleBook {
    /// Canonical KJV book order, chapter counts verified against the bundled dataset.
    static let all: [BibleBook] = [
        BibleBook(name: "Genesis", fileName: "Genesis", chapterCount: 50, testament: .old),
        BibleBook(name: "Exodus", fileName: "Exodus", chapterCount: 40, testament: .old),
        BibleBook(name: "Leviticus", fileName: "Leviticus", chapterCount: 27, testament: .old),
        BibleBook(name: "Numbers", fileName: "Numbers", chapterCount: 36, testament: .old),
        BibleBook(name: "Deuteronomy", fileName: "Deuteronomy", chapterCount: 34, testament: .old),
        BibleBook(name: "Joshua", fileName: "Joshua", chapterCount: 24, testament: .old),
        BibleBook(name: "Judges", fileName: "Judges", chapterCount: 21, testament: .old),
        BibleBook(name: "Ruth", fileName: "Ruth", chapterCount: 4, testament: .old),
        BibleBook(name: "1 Samuel", fileName: "1Samuel", chapterCount: 31, testament: .old),
        BibleBook(name: "2 Samuel", fileName: "2Samuel", chapterCount: 24, testament: .old),
        BibleBook(name: "1 Kings", fileName: "1Kings", chapterCount: 22, testament: .old),
        BibleBook(name: "2 Kings", fileName: "2Kings", chapterCount: 25, testament: .old),
        BibleBook(name: "1 Chronicles", fileName: "1Chronicles", chapterCount: 29, testament: .old),
        BibleBook(name: "2 Chronicles", fileName: "2Chronicles", chapterCount: 36, testament: .old),
        BibleBook(name: "Ezra", fileName: "Ezra", chapterCount: 10, testament: .old),
        BibleBook(name: "Nehemiah", fileName: "Nehemiah", chapterCount: 13, testament: .old),
        BibleBook(name: "Esther", fileName: "Esther", chapterCount: 10, testament: .old),
        BibleBook(name: "Job", fileName: "Job", chapterCount: 42, testament: .old),
        BibleBook(name: "Psalms", fileName: "Psalms", chapterCount: 150, testament: .old),
        BibleBook(name: "Proverbs", fileName: "Proverbs", chapterCount: 31, testament: .old),
        BibleBook(name: "Ecclesiastes", fileName: "Ecclesiastes", chapterCount: 12, testament: .old),
        BibleBook(name: "Song of Solomon", fileName: "SongofSolomon", chapterCount: 8, testament: .old),
        BibleBook(name: "Isaiah", fileName: "Isaiah", chapterCount: 66, testament: .old),
        BibleBook(name: "Jeremiah", fileName: "Jeremiah", chapterCount: 52, testament: .old),
        BibleBook(name: "Lamentations", fileName: "Lamentations", chapterCount: 5, testament: .old),
        BibleBook(name: "Ezekiel", fileName: "Ezekiel", chapterCount: 48, testament: .old),
        BibleBook(name: "Daniel", fileName: "Daniel", chapterCount: 12, testament: .old),
        BibleBook(name: "Hosea", fileName: "Hosea", chapterCount: 14, testament: .old),
        BibleBook(name: "Joel", fileName: "Joel", chapterCount: 3, testament: .old),
        BibleBook(name: "Amos", fileName: "Amos", chapterCount: 9, testament: .old),
        BibleBook(name: "Obadiah", fileName: "Obadiah", chapterCount: 1, testament: .old),
        BibleBook(name: "Jonah", fileName: "Jonah", chapterCount: 4, testament: .old),
        BibleBook(name: "Micah", fileName: "Micah", chapterCount: 7, testament: .old),
        BibleBook(name: "Nahum", fileName: "Nahum", chapterCount: 3, testament: .old),
        BibleBook(name: "Habakkuk", fileName: "Habakkuk", chapterCount: 3, testament: .old),
        BibleBook(name: "Zephaniah", fileName: "Zephaniah", chapterCount: 3, testament: .old),
        BibleBook(name: "Haggai", fileName: "Haggai", chapterCount: 2, testament: .old),
        BibleBook(name: "Zechariah", fileName: "Zechariah", chapterCount: 14, testament: .old),
        BibleBook(name: "Malachi", fileName: "Malachi", chapterCount: 4, testament: .old),
        BibleBook(name: "Matthew", fileName: "Matthew", chapterCount: 28, testament: .new),
        BibleBook(name: "Mark", fileName: "Mark", chapterCount: 16, testament: .new),
        BibleBook(name: "Luke", fileName: "Luke", chapterCount: 24, testament: .new),
        BibleBook(name: "John", fileName: "John", chapterCount: 21, testament: .new),
        BibleBook(name: "Acts", fileName: "Acts", chapterCount: 28, testament: .new),
        BibleBook(name: "Romans", fileName: "Romans", chapterCount: 16, testament: .new),
        BibleBook(name: "1 Corinthians", fileName: "1Corinthians", chapterCount: 16, testament: .new),
        BibleBook(name: "2 Corinthians", fileName: "2Corinthians", chapterCount: 13, testament: .new),
        BibleBook(name: "Galatians", fileName: "Galatians", chapterCount: 6, testament: .new),
        BibleBook(name: "Ephesians", fileName: "Ephesians", chapterCount: 6, testament: .new),
        BibleBook(name: "Philippians", fileName: "Philippians", chapterCount: 4, testament: .new),
        BibleBook(name: "Colossians", fileName: "Colossians", chapterCount: 4, testament: .new),
        BibleBook(name: "1 Thessalonians", fileName: "1Thessalonians", chapterCount: 5, testament: .new),
        BibleBook(name: "2 Thessalonians", fileName: "2Thessalonians", chapterCount: 3, testament: .new),
        BibleBook(name: "1 Timothy", fileName: "1Timothy", chapterCount: 6, testament: .new),
        BibleBook(name: "2 Timothy", fileName: "2Timothy", chapterCount: 4, testament: .new),
        BibleBook(name: "Titus", fileName: "Titus", chapterCount: 3, testament: .new),
        BibleBook(name: "Philemon", fileName: "Philemon", chapterCount: 1, testament: .new),
        BibleBook(name: "Hebrews", fileName: "Hebrews", chapterCount: 13, testament: .new),
        BibleBook(name: "James", fileName: "James", chapterCount: 5, testament: .new),
        BibleBook(name: "1 Peter", fileName: "1Peter", chapterCount: 5, testament: .new),
        BibleBook(name: "2 Peter", fileName: "2Peter", chapterCount: 3, testament: .new),
        BibleBook(name: "1 John", fileName: "1John", chapterCount: 5, testament: .new),
        BibleBook(name: "2 John", fileName: "2John", chapterCount: 1, testament: .new),
        BibleBook(name: "3 John", fileName: "3John", chapterCount: 1, testament: .new),
        BibleBook(name: "Jude", fileName: "Jude", chapterCount: 1, testament: .new),
        BibleBook(name: "Revelation", fileName: "Revelation", chapterCount: 22, testament: .new),
    ]

    static let genesis = all[0]

    static func book(named name: String) -> BibleBook? {
        all.first { $0.name == name }
    }
}
