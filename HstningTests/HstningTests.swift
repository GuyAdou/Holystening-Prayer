import Testing
import Foundation
@testable import Holystening

// MARK: - Bible version

struct BibleVersionTests {

    /// The hardcoded translation parameter must remain "kjv" after badge removal.
    @Test func bibleAPIURL_usesKJVTranslation() async throws {
        let chapter = 1
        let urlString = "https://bible-api.com/genesis+\(chapter)?translation=kjv"
        let url = try #require(URL(string: urlString))
        #expect(url.query?.contains("translation=kjv") == true)
    }

    /// Navigating chapters must keep the translation parameter intact.
    @Test func bibleAPIURL_KJVPersistsAcrossChapters() async throws {
        for chapter in 1...3 {
            let urlString = "https://bible-api.com/genesis+\(chapter)?translation=kjv"
            let url = try #require(URL(string: urlString))
            #expect(url.query?.contains("translation=kjv") == true, "Chapter \(chapter) must use KJV")
        }
    }
}
