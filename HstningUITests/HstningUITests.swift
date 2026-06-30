import XCTest

final class HstningUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    // MARK: - Helpers

    @MainActor
    private func launchApp(onboardingComplete: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-UITesting", "-hasCompletedOnboarding", onboardingComplete ? "1" : "0"]
        app.launch()
        return app
    }

    @MainActor
    private func launchOnboarding() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-UITesting", "-hasCompletedOnboarding", "0"]
        app.launch()
        return app
    }

    @MainActor
    private func openNotes(in app: XCUIApplication) {
        app.buttons["notes-pill-button"].tap()
    }

    // MARK: - Bible: toolbar + content

    @MainActor
    func testBibleToolbar_noKJVBadge() throws {
        let app = launchApp()
        app.buttons["bible-pill-button"].tap()
        _ = app.navigationBars.firstMatch.waitForExistence(timeout: 3)
        XCTAssertFalse(app.navigationBars.buttons["KJV"].exists)
    }

    @MainActor
    func testBibleContent_versionNoteExists() throws {
        let app = launchApp()
        app.buttons["bible-pill-button"].tap()
        XCTAssertTrue(app.staticTexts["bible-version-note"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testBibleContent_versionNoteIsNotInteractive() throws {
        let app = launchApp()
        app.buttons["bible-pill-button"].tap()
        XCTAssertTrue(app.staticTexts["bible-version-note"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["bible-version-note"].exists)
    }

    @MainActor
    func testBibleContent_versionNotePersistsAcrossChapters() throws {
        let app = launchApp()
        app.buttons["bible-pill-button"].tap()
        _ = app.staticTexts["bible-version-note"].waitForExistence(timeout: 5)
        app.buttons["bible-next-chapter"].tap()
        _ = app.staticTexts["Chapter 2"].waitForExistence(timeout: 5)
        XCTAssertTrue(app.staticTexts["bible-version-note"].exists)
    }

    // MARK: - Bible: cross-feature

    @MainActor
    func testBible_opensFromHomePill() throws {
        let app = launchApp()
        XCTAssertTrue(app.buttons["bible-pill-button"].waitForExistence(timeout: 3))
        app.buttons["bible-pill-button"].tap()
        XCTAssertTrue(app.staticTexts["Genesis 1"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testBible_opensFromPrayerSessionPill() throws {
        let app = launchApp()
        XCTAssertTrue(app.buttons["prayer-play-button"].waitForExistence(timeout: 3))
        app.buttons["prayer-play-button"].tap()
        XCTAssertTrue(app.buttons["bible-pill-button"].waitForExistence(timeout: 3))
        app.buttons["bible-pill-button"].tap()
        XCTAssertTrue(app.staticTexts["Genesis 1"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testBible_dismissDuringSessionKeepsSessionActive() throws {
        let app = launchApp()
        XCTAssertTrue(app.buttons["prayer-play-button"].waitForExistence(timeout: 3))
        app.buttons["prayer-play-button"].tap()
        XCTAssertTrue(app.buttons["bible-pill-button"].waitForExistence(timeout: 3))
        app.buttons["bible-pill-button"].tap()
        XCTAssertTrue(app.staticTexts["Genesis 1"].waitForExistence(timeout: 5))
        let closeBtn = app.buttons.matching(NSPredicate(format: "label == 'Close'")).firstMatch
        XCTAssertTrue(closeBtn.waitForExistence(timeout: 5), "Close button must exist in Bible")
        closeBtn.tap()
        XCTAssertTrue(
            app.buttons.matching(NSPredicate(format: "label CONTAINS 'Stop'")).firstMatch.waitForExistence(timeout: 3),
            "Session must still be active after dismissing Bible"
        )
    }

    // MARK: - Pill: always visible

    @MainActor
    func testPill_visibleDuringPrayerSession() throws {
        let app = launchApp()
        XCTAssertTrue(app.buttons["prayer-play-button"].waitForExistence(timeout: 3))
        app.buttons["prayer-play-button"].tap()
        XCTAssertTrue(app.buttons["bible-pill-button"].waitForExistence(timeout: 3), "Bible pill must be visible during session")
        XCTAssertTrue(app.buttons["notes-pill-button"].exists, "Notes pill must be visible during session")
    }

    @MainActor
    func testNotes_opensDuringPrayerSession() throws {
        let app = launchApp()
        XCTAssertTrue(app.buttons["prayer-play-button"].waitForExistence(timeout: 3))
        app.buttons["prayer-play-button"].tap()
        XCTAssertTrue(app.buttons["notes-pill-button"].waitForExistence(timeout: 3))
        app.buttons["notes-pill-button"].tap()
        XCTAssertTrue(app.navigationBars["Notes"].waitForExistence(timeout: 3), "Notes must open during prayer session")
    }

    // MARK: - Notes: close button

    @MainActor
    func testNotes_hasCloseButton() throws {
        let app = launchApp()
        openNotes(in: app)
        XCTAssertTrue(app.buttons["notes-close-button"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testNotes_closeButtonDismissesSheet() throws {
        let app = launchApp()
        openNotes(in: app)
        XCTAssertTrue(app.buttons["notes-close-button"].waitForExistence(timeout: 3))
        app.buttons["notes-close-button"].tap()
        XCTAssertTrue(app.buttons["notes-pill-button"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testNotes_closeButtonWorksFromInsideNote() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons["notes-close-button"].waitForExistence(timeout: 3)
        app.buttons["notes-new-button"].tap()
        _ = app.textViews["note-body-editor"].waitForExistence(timeout: 3)
        app.navigationBars.buttons["Notes"].tap()
        XCTAssertTrue(app.buttons["notes-close-button"].waitForExistence(timeout: 3))
        app.buttons["notes-close-button"].tap()
        XCTAssertTrue(app.buttons["notes-pill-button"].waitForExistence(timeout: 3))
    }

    // MARK: - Notes: focus behavior

    @MainActor
    func testNotes_newNote_cursorInBody() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons["notes-new-button"].waitForExistence(timeout: 3)
        app.buttons["notes-new-button"].tap()
        let bodyEditor = app.textViews["note-body-editor"]
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 3))
        XCTAssertTrue(bodyEditor.value(forKey: "hasKeyboardFocus") as? Bool ?? false,
                      "New note must auto-focus the body")
    }

    @MainActor
    func testNotes_existingNote_noAutoFocus() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons["notes-new-button"].waitForExistence(timeout: 3)
        app.buttons["notes-new-button"].tap()
        let titleField = app.textFields["note-title-field"]
        _ = titleField.waitForExistence(timeout: 3)
        titleField.tap()
        titleField.typeText("Test Note")
        app.navigationBars.buttons["Notes"].tap()
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 3))
        app.cells.firstMatch.tap()
        let bodyEditor = app.textViews["note-body-editor"]
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 3))
        XCTAssertFalse(bodyEditor.value(forKey: "hasKeyboardFocus") as? Bool ?? false,
                       "Existing note must not auto-focus the body")
    }

    // MARK: - Note editor: Done button

    @MainActor
    func testNoteEditor_hasDoneButton() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons["notes-new-button"].waitForExistence(timeout: 3)
        app.buttons["notes-new-button"].tap()
        XCTAssertTrue(app.buttons["note-done-button"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testNoteEditor_doneButtonDismissesKeyboard() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons["notes-new-button"].waitForExistence(timeout: 3)
        app.buttons["notes-new-button"].tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3), "Keyboard must appear on new note")
        app.buttons["note-done-button"].tap()
        XCTAssertFalse(app.keyboards.firstMatch.exists, "Keyboard must be dismissed after tapping Done")
    }

    // MARK: - Settings

    @MainActor
    func testSettings_noFocusModeSection() throws {
        let app = launchApp()
        app.buttons["settings-gear-button"].tap()
        _ = app.navigationBars["Settings"].waitForExistence(timeout: 3)
        XCTAssertFalse(app.staticTexts["Focus Mode"].exists)
    }

    @MainActor
    func testSettings_requiredSectionsExist() throws {
        let app = launchApp()
        app.buttons["settings-gear-button"].tap()
        _ = app.navigationBars["Settings"].waitForExistence(timeout: 3)
        XCTAssertTrue(app.staticTexts["Prayer Audio"].exists)
        XCTAssertTrue(app.staticTexts["Interruptions"].exists)
    }

    // MARK: - Onboarding layout

    @MainActor
    func testWelcome_ctaHittableOnSmallDevice() throws {
        let app = launchOnboarding()
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Get started'")).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 3))
        XCTAssertTrue(cta.isHittable)
    }

    @MainActor
    func testWelcome_allFeatureRowsVisibleOnSmallDevice() throws {
        let app = launchOnboarding()
        _ = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Get started'")).firstMatch.waitForExistence(timeout: 3)
        for label in ["Pray without distractions", "Bible", "Notes"] {
            XCTAssertTrue(app.staticTexts[label].exists, "'\(label)' must be visible")
        }
    }

    @MainActor
    func testSilence_ctaHittableOnSmallDevice() throws {
        let app = launchOnboarding()
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Get started'")).firstMatch.tap()
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Open Settings'")).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 3))
        XCTAssertTrue(cta.isHittable)
    }

    @MainActor
    func testSilence_allStepRowsVisibleOnSmallDevice() throws {
        let app = launchOnboarding()
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Get started'")).firstMatch.tap()
        _ = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Open Settings'")).firstMatch.waitForExistence(timeout: 3)
        for label in ["Open Settings", "Choose a Focus", "Set a schedule", "Add Holystening"] {
            XCTAssertTrue(app.staticTexts[label].exists, "'\(label)' must be visible")
        }
    }

    @MainActor
    func testCongrats_ctaHittableOnSmallDevice() throws {
        let app = launchOnboarding()
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Get started'")).firstMatch.tap()
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

    // MARK: - Dark mode

    @MainActor
    func testBible_contentVisibleInDarkMode() throws {
        XCUIDevice.shared.appearance = .dark
        defer { XCUIDevice.shared.appearance = .unspecified }
        let app = launchApp()
        app.buttons["bible-pill-button"].tap()
        XCTAssertTrue(app.staticTexts["Genesis 1"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["bible-version-note"].waitForExistence(timeout: 8))
    }

    @MainActor
    func testHome_pillsHittableInDarkMode() throws {
        XCUIDevice.shared.appearance = .dark
        defer { XCUIDevice.shared.appearance = .unspecified }
        let app = launchApp()
        XCTAssertTrue(app.buttons["bible-pill-button"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["bible-pill-button"].isHittable)
        XCTAssertTrue(app.buttons["notes-pill-button"].isHittable)
        XCTAssertTrue(app.buttons["prayer-play-button"].isHittable)
    }

    @MainActor
    func testOnboarding_ctaHittableInDarkMode() throws {
        XCUIDevice.shared.appearance = .dark
        defer { XCUIDevice.shared.appearance = .unspecified }
        let app = launchOnboarding()
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Get started'")).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 3))
        XCTAssertTrue(cta.isHittable)
    }

    // MARK: - Launch performance

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
