import SwiftData
import Foundation

@Model
final class NoteFolder {
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var notes: [Note] = []

    init(name: String) {
        self.name = name
        self.createdAt = .now
    }
}
