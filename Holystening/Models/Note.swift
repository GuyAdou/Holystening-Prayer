import SwiftData
import Foundation

@Model
final class Note {
    var title: String
    var content: String
    var drawingData: Data?
    var createdAt: Date
    var updatedAt: Date
    var folder: NoteFolder?

    init(title: String = "", content: String = "", folder: NoteFolder? = nil) {
        self.title = title
        self.content = content
        self.createdAt = .now
        self.updatedAt = .now
        self.folder = folder
    }

    var displayTitle: String { title.isEmpty ? "New Note" : title }

    var preview: String {
        String((content.components(separatedBy: "\n").first(where: { !$0.isEmpty }) ?? "").prefix(80))
    }

    var formattedDate: String {
        let cal = Calendar.current
        if cal.isDateInToday(updatedAt) {
            return updatedAt.formatted(date: .omitted, time: .shortened)
        } else if cal.isDateInYesterday(updatedAt) {
            return "Yesterday"
        }
        return updatedAt.formatted(date: .abbreviated, time: .omitted)
    }
}
