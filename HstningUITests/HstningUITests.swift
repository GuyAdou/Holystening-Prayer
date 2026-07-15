import XCTest

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Base test case
//
// All UI test classes inherit from AppUITestCase.
// - Shared launch helpers so they never need to be rewritten per feature.
// - AID namespace: every accessibility identifier lives here. When an ID
//   changes in the app, update it once here and every test stays correct.
// - Flow helpers: openBible, openNotes, startSession, etc. are the building
//   blocks for writing new feature tests without repeating boilerplate.
//
// To add tests for a new feature:
//   1. Create a new `final class MyFeatureUITests: AppUITestCase` below.
//   2. Write `@MainActor func test…` methods using the helpers.
//   3. Add any new accessibility identifiers to AID.
// ─────────────────────────────────────────────────────────────────────────────

class AppUITestCase: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: Accessibility identifiers — single source of truth

    enum AID {
        // Home
        static let playButton     = "prayer-play-button"
        static let settingsGear   = "settings-gear-button"
        // Pills
        static let biblePill      = "bible-pill-button"
        static let notesPill      = "notes-pill-button"
        // Bible
        static let bibleClose     = "bible-close-button"
        static let biblePrev      = "bible-prev-chapter"
        static let bibleNext      = "bible-next-chapter"
        static let bibleVersion   = "bible-version-note"
        static let biblePickerTrigger = "bible-picker-trigger"
        // Notes list
        static let notesClose     = "notes-close-button"
        static let notesNew       = "notes-new-button"
        // Note editor
        static let noteTitleField = "note-title-field"
        static let noteBody       = "note-body-editor"
        static let noteDone       = "note-done-button"
    }

    // MARK: Launch helpers

    @MainActor
    func launchApp(onboardingComplete: Bool = true, darkMode: Bool = false) -> XCUIApplication {
        if darkMode { XCUIDevice.shared.appearance = .dark }
        let app = XCUIApplication()
        app.launchArguments += ["-UITesting", "-hasCompletedOnboarding", onboardingComplete ? "1" : "0"]
        app.launch()
        return app
    }

    @MainActor
    func launchOnboarding(darkMode: Bool = false) -> XCUIApplication {
        launchApp(onboardingComplete: false, darkMode: darkMode)
    }

    // MARK: Flow helpers

    /// Taps the play button and waits for the Stop button to confirm the session started.
    @MainActor
    @discardableResult
    func startSession(in app: XCUIApplication) -> XCUIApplication {
        XCTAssertTrue(app.buttons[AID.playButton].waitForExistence(timeout: 3))
        app.buttons[AID.playButton].tap()
        _ = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Stop'")).firstMatch
            .waitForExistence(timeout: 5)
        return app
    }

    /// Opens the Bible sheet and waits for the Genesis 1 picker trigger to confirm the content loaded.
    @MainActor
    func openBible(in app: XCUIApplication) {
        XCTAssertTrue(app.buttons[AID.biblePill].waitForExistence(timeout: 3))
        app.buttons[AID.biblePill].tap()
        _ = app.buttons[AID.biblePickerTrigger].waitForExistence(timeout: 5)
    }

    /// Opens the Notes sheet and waits for the Notes navigation bar to appear.
    @MainActor
    func openNotes(in app: XCUIApplication) {
        XCTAssertTrue(app.buttons[AID.notesPill].waitForExistence(timeout: 3))
        app.buttons[AID.notesPill].tap()
        _ = app.navigationBars["Notes"].waitForExistence(timeout: 3)
    }

    /// Opens Settings and waits for the Settings navigation bar.
    @MainActor
    func openSettings(in app: XCUIApplication) {
        XCTAssertTrue(app.buttons[AID.settingsGear].waitForExistence(timeout: 3))
        app.buttons[AID.settingsGear].tap()
        _ = app.navigationBars["Settings"].waitForExistence(timeout: 3)
    }

    /// Taps the "Continue" CTA on the Welcome onboarding screen.
    @MainActor
    func advanceOnboarding(in app: XCUIApplication) {
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Continue'")).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 3))
        cta.tap()
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Home & Prayer Session
// ─────────────────────────────────────────────────────────────────────────────

final class HomeUITests: AppUITestCase {

    @MainActor
    func testApp_launchesToHomeScreen() throws {
        let app = launchApp()
        XCTAssertTrue(app.buttons[AID.playButton].waitForExistence(timeout: 5))
    }

    @MainActor
    func testHome_playButtonStartsSession() throws {
        let app = launchApp()
        app.buttons[AID.playButton].tap()
        XCTAssertTrue(
            app.buttons.matching(NSPredicate(format: "label CONTAINS 'Stop'")).firstMatch
                .waitForExistence(timeout: 5),
            "Stop button must appear once session starts"
        )
    }

    @MainActor
    func testHome_stopButtonEndsSession() throws {
        let app = launchApp()
        startSession(in: app)
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Stop'")).firstMatch.tap()
        XCTAssertTrue(app.buttons[AID.playButton].waitForExistence(timeout: 5))
    }

    @MainActor
    func testHome_settingsGearOpensSettings() throws {
        let app = launchApp()
        openSettings(in: app)
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Pills (Notes + Bible)
// ─────────────────────────────────────────────────────────────────────────────

final class PillUITests: AppUITestCase {

    @MainActor
    func testPills_visibleOnHomeScreen() throws {
        let app = launchApp()
        XCTAssertTrue(app.buttons[AID.biblePill].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons[AID.notesPill].exists)
    }

    @MainActor
    func testPills_visibleDuringPrayerSession() throws {
        let app = launchApp()
        startSession(in: app)
        XCTAssertTrue(app.buttons[AID.biblePill].exists, "Bible pill must stay visible during session")
        XCTAssertTrue(app.buttons[AID.notesPill].exists, "Notes pill must stay visible during session")
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Bible
// ─────────────────────────────────────────────────────────────────────────────

final class BibleUITests: AppUITestCase {

    @MainActor
    func testBible_opensFromHomePill() throws {
        let app = launchApp()
        openBible(in: app)
        XCTAssertTrue(app.buttons[AID.biblePickerTrigger].exists)
    }

    @MainActor
    func testBible_opensFromPrayerSessionPill() throws {
        let app = launchApp()
        startSession(in: app)
        openBible(in: app)
        XCTAssertTrue(app.buttons[AID.biblePickerTrigger].exists)
    }

    @MainActor
    func testBible_hasCloseButton() throws {
        let app = launchApp()
        openBible(in: app)
        XCTAssertTrue(
            app.buttons.matching(NSPredicate(format: "label == 'Close'")).firstMatch
                .waitForExistence(timeout: 3)
        )
    }

    @MainActor
    func testBible_closeButtonDismissesSheet() throws {
        let app = launchApp()
        openBible(in: app)
        app.buttons.matching(NSPredicate(format: "label == 'Close'")).firstMatch.tap()
        XCTAssertTrue(app.buttons[AID.biblePill].waitForExistence(timeout: 3))
    }

    @MainActor
    func testBible_dismissDuringSessionKeepsSessionActive() throws {
        let app = launchApp()
        startSession(in: app)
        openBible(in: app)
        let closeBtn = app.buttons.matching(NSPredicate(format: "label == 'Close'")).firstMatch
        XCTAssertTrue(closeBtn.waitForExistence(timeout: 5))
        closeBtn.tap()
        XCTAssertTrue(
            app.buttons.matching(NSPredicate(format: "label CONTAINS 'Stop'")).firstMatch
                .waitForExistence(timeout: 3),
            "Prayer session must remain active after dismissing Bible"
        )
    }

    @MainActor
    func testBible_noKJVBadgeInToolbar() throws {
        let app = launchApp()
        openBible(in: app)
        XCTAssertFalse(app.navigationBars.buttons["KJV"].exists)
    }

    @MainActor
    func testBible_versionNoteExists() throws {
        let app = launchApp()
        openBible(in: app)
        XCTAssertTrue(app.staticTexts[AID.bibleVersion].waitForExistence(timeout: 8))
    }

    @MainActor
    func testBible_versionNoteIsNotInteractive() throws {
        let app = launchApp()
        openBible(in: app)
        _ = app.staticTexts[AID.bibleVersion].waitForExistence(timeout: 5)
        XCTAssertFalse(app.buttons[AID.bibleVersion].exists)
    }

    @MainActor
    func testBible_versionNotePersistsAcrossChapters() throws {
        let app = launchApp()
        openBible(in: app)
        app.buttons[AID.bibleNext].tap()
        _ = app.staticTexts["Chapter 2"].waitForExistence(timeout: 5)
        XCTAssertTrue(app.staticTexts[AID.bibleVersion].exists)
    }

    @MainActor
    func testBible_pickerOpensFromTitle() throws {
        let app = launchApp()
        openBible(in: app)
        app.buttons[AID.biblePickerTrigger].tap()
        XCTAssertTrue(app.buttons["bible-book-Genesis"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testBible_pickerNavigatesToSelectedBookAndChapter() throws {
        let app = launchApp()
        openBible(in: app)
        app.buttons[AID.biblePickerTrigger].tap()
        _ = app.buttons["bible-book-Genesis"].waitForExistence(timeout: 3)

        app.buttons["bible-book-John"].tap()
        let chapter3 = app.buttons["bible-chapter-3"]
        XCTAssertTrue(chapter3.waitForExistence(timeout: 3))
        chapter3.tap()

        let trigger = app.buttons[AID.biblePickerTrigger]
        XCTAssertTrue(trigger.waitForExistence(timeout: 3))
        XCTAssertTrue(trigger.label.contains("John"))
        XCTAssertTrue(trigger.label.contains("3"))
    }

    @MainActor
    func testBible_pickerBackButtonReturnsToBookList() throws {
        let app = launchApp()
        openBible(in: app)
        app.buttons[AID.biblePickerTrigger].tap()
        _ = app.buttons["bible-book-Genesis"].waitForExistence(timeout: 3)

        app.buttons["bible-book-Psalms"].tap()
        XCTAssertTrue(app.buttons["bible-chapter-1"].waitForExistence(timeout: 3))

        app.buttons["bible-picker-back-to-books"].tap()
        XCTAssertTrue(app.buttons["bible-book-Genesis"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testBible_nextChapterCrossesIntoNextBook() throws {
        let app = launchApp()
        openBible(in: app)
        app.buttons[AID.biblePickerTrigger].tap()
        _ = app.buttons["bible-book-Genesis"].waitForExistence(timeout: 3)
        app.buttons["bible-book-Ruth"].tap()
        app.buttons["bible-chapter-4"].tap()

        _ = app.buttons[AID.biblePickerTrigger].waitForExistence(timeout: 3)
        app.buttons[AID.bibleNext].tap()

        let trigger = app.buttons[AID.biblePickerTrigger]
        XCTAssertTrue(trigger.waitForExistence(timeout: 3))
        XCTAssertTrue(trigger.label.contains("1 Samuel"), "Chapter Next from Ruth 4 (its last chapter) must roll into 1 Samuel 1")
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Notes
// ─────────────────────────────────────────────────────────────────────────────

final class NotesUITests: AppUITestCase {

    @MainActor
    func testNotes_opensDuringPrayerSession() throws {
        let app = launchApp()
        startSession(in: app)
        openNotes(in: app)
        XCTAssertTrue(app.navigationBars["Notes"].exists)
    }

    @MainActor
    func testNotes_hasCloseButton() throws {
        let app = launchApp()
        openNotes(in: app)
        XCTAssertTrue(app.buttons[AID.notesClose].waitForExistence(timeout: 3))
    }

    @MainActor
    func testNotes_closeButtonDismissesSheet() throws {
        let app = launchApp()
        openNotes(in: app)
        app.buttons[AID.notesClose].tap()
        XCTAssertTrue(app.buttons[AID.notesPill].waitForExistence(timeout: 3))
    }

    @MainActor
    func testNotes_closeButtonWorksFromInsideNote() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons[AID.notesClose].waitForExistence(timeout: 3)
        app.buttons[AID.notesNew].tap()
        _ = app.textViews[AID.noteBody].waitForExistence(timeout: 3)
        app.navigationBars.buttons["Notes"].tap()
        XCTAssertTrue(app.buttons[AID.notesClose].waitForExistence(timeout: 3))
        app.buttons[AID.notesClose].tap()
        XCTAssertTrue(app.buttons[AID.notesPill].waitForExistence(timeout: 3))
    }

    @MainActor
    func testNotes_newNote_cursorInBody() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons[AID.notesNew].waitForExistence(timeout: 3)
        app.buttons[AID.notesNew].tap()
        let bodyEditor = app.textViews[AID.noteBody]
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 3))
        XCTAssertTrue(
            bodyEditor.value(forKey: "hasKeyboardFocus") as? Bool ?? false,
            "New note must auto-focus the body"
        )
    }

    @MainActor
    func testNotes_existingNote_noAutoFocus() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons[AID.notesNew].waitForExistence(timeout: 3)
        app.buttons[AID.notesNew].tap()
        let titleField = app.textFields[AID.noteTitleField]
        _ = titleField.waitForExistence(timeout: 3)
        titleField.tap()
        titleField.typeText("Test Note")
        app.navigationBars.buttons["Notes"].tap()
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 3))
        app.cells.firstMatch.tap()
        let bodyEditor = app.textViews[AID.noteBody]
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 3))
        XCTAssertFalse(
            bodyEditor.value(forKey: "hasKeyboardFocus") as? Bool ?? false,
            "Existing note must not auto-focus the body"
        )
    }

    @MainActor
    func testNoteEditor_hasDoneButton() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons[AID.notesNew].waitForExistence(timeout: 3)
        app.buttons[AID.notesNew].tap()
        XCTAssertTrue(app.buttons[AID.noteDone].waitForExistence(timeout: 3))
    }

    @MainActor
    func testNoteEditor_doneButtonDismissesKeyboard() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons[AID.notesNew].waitForExistence(timeout: 3)
        app.buttons[AID.notesNew].tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3), "Keyboard must appear on new note")
        app.buttons[AID.noteDone].tap()
        XCTAssertFalse(app.keyboards.firstMatch.exists, "Keyboard must be dismissed after tapping Done")
    }

    @MainActor
    func testNoteEditor_checkmarkTurnsGrayAfterSave() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons[AID.notesNew].waitForExistence(timeout: 3)
        app.buttons[AID.notesNew].tap()
        let checkmark = app.buttons[AID.noteDone]
        XCTAssertTrue(checkmark.waitForExistence(timeout: 3), "Checkmark must always be visible")
        XCTAssertEqual(checkmark.value as? String, "unsaved", "New note starts unsaved (gold)")

        checkmark.tap()
        XCTAssertEqual(checkmark.value as? String, "saved", "Checkmark must turn gray once the note is saved")
    }

    @MainActor
    func testNoteEditor_checkmarkTurnsGoldWhenEditingAgain() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons[AID.notesNew].waitForExistence(timeout: 3)
        app.buttons[AID.notesNew].tap()
        let checkmark = app.buttons[AID.noteDone]
        _ = checkmark.waitForExistence(timeout: 3)
        checkmark.tap()
        XCTAssertEqual(checkmark.value as? String, "saved")

        let bodyEditor = app.textViews[AID.noteBody]
        bodyEditor.tap()
        bodyEditor.typeText("More thoughts")
        XCTAssertEqual(
            checkmark.value as? String, "unsaved",
            "Checkmark must turn gold again once typing resumes after a save"
        )
    }

    @MainActor
    func testNoteEditor_existingSavedNote_checkmarkStaysGrayUntilEdited() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons[AID.notesNew].waitForExistence(timeout: 3)
        app.buttons[AID.notesNew].tap()
        let titleField = app.textFields[AID.noteTitleField]
        _ = titleField.waitForExistence(timeout: 3)
        titleField.tap()
        titleField.typeText("Saved note")
        app.buttons[AID.noteDone].tap()
        app.navigationBars.buttons["Notes"].tap()

        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 3))
        app.cells.firstMatch.tap()
        let checkmark = app.buttons[AID.noteDone]
        XCTAssertTrue(checkmark.waitForExistence(timeout: 3))
        XCTAssertEqual(
            checkmark.value as? String, "saved",
            "Checkmark must stay gray when reopening an already-saved, unedited note"
        )
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Settings
// ─────────────────────────────────────────────────────────────────────────────

final class SettingsUITests: AppUITestCase {

    @MainActor
    func testSettings_requiredSectionsExist() throws {
        let app = launchApp()
        openSettings(in: app)
        XCTAssertTrue(app.staticTexts["Prayer Audio"].exists)
        XCTAssertTrue(app.staticTexts["Interruptions"].exists)
    }

    @MainActor
    func testSettings_noFocusModeSection() throws {
        let app = launchApp()
        openSettings(in: app)
        XCTAssertFalse(app.staticTexts["Focus Mode"].exists)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Onboarding
// ─────────────────────────────────────────────────────────────────────────────

final class OnboardingUITests: AppUITestCase {

    @MainActor
    func testWelcome_ctaHittable() throws {
        let app = launchOnboarding()
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Continue'")).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 3))
        XCTAssertTrue(cta.isHittable)
    }

    @MainActor
    func testWelcome_allFeatureRowsVisible() throws {
        let app = launchOnboarding()
        _ = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Continue'")).firstMatch
            .waitForExistence(timeout: 3)
        for label in ["Pray without distractions", "Bible", "Notes"] {
            XCTAssertTrue(app.staticTexts[label].exists, "'\(label)' must be visible on Welcome screen")
        }
    }

    @MainActor
    func testSilence_ctaHittable() throws {
        let app = launchOnboarding()
        advanceOnboarding(in: app)
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Open Settings'")).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 3))
        XCTAssertTrue(cta.isHittable)
    }

    @MainActor
    func testSilence_allStepRowsVisible() throws {
        let app = launchOnboarding()
        advanceOnboarding(in: app)
        _ = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Open Settings'")).firstMatch
            .waitForExistence(timeout: 3)
        for label in ["Open Settings", "Choose a Focus", "Set a schedule", "Add Holystening"] {
            XCTAssertTrue(app.staticTexts[label].exists, "'\(label)' must be visible on Silence screen")
        }
    }

    @MainActor
    func testCongrats_ctaHittable() throws {
        let app = launchOnboarding()
        advanceOnboarding(in: app)
        let openSettings = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Open Settings'")).firstMatch
        XCTAssertTrue(openSettings.waitForExistence(timeout: 3))
        openSettings.tap()
        let done = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Done'")).firstMatch
        XCTAssertTrue(done.waitForExistence(timeout: 3))
        done.tap()
        let startCTA = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Start'")).firstMatch
        XCTAssertTrue(startCTA.waitForExistence(timeout: 3))
        XCTAssertTrue(startCTA.isHittable)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Dark Mode
// ─────────────────────────────────────────────────────────────────────────────

final class DarkModeUITests: AppUITestCase {

    override func tearDownWithError() throws {
        XCUIDevice.shared.appearance = .unspecified
    }

    @MainActor
    func testHome_pillsHittableInDarkMode() throws {
        let app = launchApp(darkMode: true)
        XCTAssertTrue(app.buttons[AID.biblePill].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons[AID.biblePill].isHittable)
        XCTAssertTrue(app.buttons[AID.notesPill].isHittable)
        XCTAssertTrue(app.buttons[AID.playButton].isHittable)
    }

    @MainActor
    func testBible_contentVisibleInDarkMode() throws {
        let app = launchApp(darkMode: true)
        openBible(in: app)
        XCTAssertTrue(app.buttons[AID.biblePickerTrigger].exists)
        XCTAssertTrue(app.staticTexts[AID.bibleVersion].waitForExistence(timeout: 8))
    }

    @MainActor
    func testOnboarding_ctaHittableInDarkMode() throws {
        let app = launchOnboarding(darkMode: true)
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Continue'")).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 3))
        XCTAssertTrue(cta.isHittable)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Performance
// ─────────────────────────────────────────────────────────────────────────────

final class PerformanceUITests: AppUITestCase {

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
