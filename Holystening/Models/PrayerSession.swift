import Foundation

struct PrayerTrack: Identifiable, Hashable {
    let id: UUID
    let name: String
    let fileName: String
    let fileExtension: String

    init(id: UUID = UUID(), name: String, fileName: String, fileExtension: String = "mp3") {
        self.id = id
        self.name = name
        self.fileName = fileName
        self.fileExtension = fileExtension
    }
}

struct AppSettings {
    var selectedTrackIndex: Int = AppConfig.defaultTrackIndex
    var selectedFocusName: String = AppConfig.defaultFocusMode

    static var availableFocusModes: [String] { AppConfig.focusModes }
    static var availableTracks: [PrayerTrack] { AppConfig.tracks }
}
