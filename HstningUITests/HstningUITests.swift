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
    private func openNotes(in app: XCUIApplication) {
        app.buttons["notes-pill-button"].tap()
    }

    // MARK: - Bible: toolbar badge

    @MainActor
    func testBibleToolbar_noKJVBadge() throws {
        let app = launchApp()
        app.buttons["bible-pill-button"].tap()
        _ = app.navigationBars.firstMatch.waitForExistence(timeout: 3)
        XCTAssertFalse(app.navigationBars.buttons["KJV"].exists)
    }

    // MARK: - Bible: version note in scroll content

    @MainActor
    func testBibleContent_versionNoteExists() throws {
        let app = launchApp()
        app.buttons["bible-pill-button"].tap()
        XCTAssertTrue(app.staticTexts["bible-version-note"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testBibleContent_versionNoteIsNotInteractive() throws {
        let app = launchApp()
        app.buttons["bible-pill-button"].tap()
        XCTAssertTrue(app.staticTexts["bible-version-note"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["bible-version-note"].exists)
    }

    @MainActor
    func testBibleContent_versionNotePersistsAcrossChapters() throws {
        let app = launchApp()
        app.buttons["bible-pill-button"].tap()
        _ = app.staticTexts["bible-version-note"].waitForExistence(timeout: 3)
        app.buttons["bible-next-chapter"].tap()
        _ = app.staticTexts["Chapter 2"].waitForExistence(timeout: 5)
        XCTAssertTrue(app.staticTexts["bible-version-note"].exists)
    }

    // MARK: - Bible: cross-feature

    @MainActor
    func testBible_opensFromHomePill() throws {
        let app = launchApp()
        let bibleBtn = app.buttons["bible-pill-button"]
        XCTAssertTrue(bibleBtn.waitForExistence(timeout: 3))
        bibleBtn.tap()
        XCTAssertTrue(app.staticTexts["Genesis 1"].waitForExistence(timeout: 3))
    }

    /// Pill (Bible + Notes) must be visible during an active prayer session.
    @MainActor
    func testPill_visibleDuringPrayerSession() throws {
        let app = launchApp()
        let playBtn = app.buttons["prayer-play-button"]
        XCTAssertTrue(playBtn.waitForExistence(timeout: 3))
        playBtn.tap()
        XCTAssertTrue(
            app.buttons["bible-pill-button"].waitForExistence(timeout: 3),
            "Bible pill must be visible during prayer session"
        )
        XCTAssertTrue(
            app.buttons["notes-pill-button"].exists,
            "Notes pill must be visible during prayer session"
        )
    }

    /// Bible opens from the pill during an active prayer session.
    @MainActor
    func testBible_opensFromPrayerSessionPill() throws {
        let app = launchApp()
        let playBtn = app.buttons["prayer-play-button"]
        XCTAssertTrue(playBtn.waitForExistence(timeout: 3))
        playBtn.tap()
        let bibleBtn = app.buttons["bible-pill-button"]
        XCTAssertTrue(bibleBtn.waitForExistence(timeout: 3))
        bibleBtn.tap()
        XCTAssertTrue(app.staticTexts["Genesis 1"].waitForExistence(timeout: 3))
    }

    /// Notes open from the pill during an active prayer session.
    @MainActor
    func testNotes_opensDuringPrayerSession() throws {
        let app = launchApp()
        let playBtn = app.buttons["prayer-play-button"]
        XCTAssertTrue(playBtn.waitForExistence(timeout: 3))
        playBtn.tap()
        let notesBtn = app.buttons["notes-pill-button"]
        XCTAssertTrue(notesBtn.waitForExistence(timeout: 3))
        notesBtn.tap()
        XCTAssertTrue(
            app.navigationBars["Notes"].waitForExistence(timeout: 3),
            "Notes sheet must open during prayer session"
        )
    }

    @MainActor
    func testBible_dismissDuringSessionKeepsSessionActive() throws {
        let app = launchApp()
        let playBtn = app.buttons["prayer-play-button"]
        XCTAssertTrue(playBtn.waitForExistence(timeout: 3))
        playBtn.tap()
        let bibleBtn = app.buttons["bible-pill-button"]
        XCTAssertTrue(bibleBtn.waitForExistence(timeout: 3))
        bibleBtn.tap()
        // Confirm Bible opened before searching for close button
        XCTAssertTrue(app.staticTexts["Genesis 1"].waitForExistence(timeout: 5))
        let closeBtn = app.buttons.matching(NSPredicate(format: "label == 'Close'")).firstMatch
        if !closeBtn.waitForExistence(timeout: 5) {
            XCTFail("Close button not found.\n\(app.debugDescription)")
        }
        closeBtn.tap()
        // Session stop button must still be present — session remained active
        XCTAssertTrue(
            app.buttons.matching(NSPredicate(format: "label CONTAINS 'Stop'")).firstMatch.waitForExistence(timeout: 3),
            "Prayer session must still be active after dismissing Bible"
        )
    }

    // MARK: - Notes: close button

    /// Notes sheet must have a Close button that dismisses it.
    @MainActor
    func testNotes_hasCloseButton() throws {
        let app = launchApp()
        openNotes(in: app)
        XCTAssertTrue(
            app.buttons["notes-close-button"].waitForExistence(timeout: 3),
            "Notes sheet must have a Close button"
        )
    }

    /// Tapping Close on Notes must return to the home screen.
    @MainActor
    func testNotes_closeButtonDismissesSheet() throws {
        let app = launchApp()
        openNotes(in: app)
        XCTAssertTrue(app.buttons["notes-close-button"].waitForExistence(timeout: 3))
        app.buttons["notes-close-button"].tap()
        XCTAssertTrue(
            app.buttons["notes-pill-button"].waitForExistence(timeout: 3),
            "Home screen pill must reappear after Notes is dismissed"
        )
    }

    /// Close button must still work after navigating into a note.
    @MainActor
    func testNotes_closeButtonWorksFromInsideNote() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons["notes-close-button"].waitForExistence(timeout: 3)
        // Create a new note
        app.buttons["notes-new-button"].tap()
        // Navigate back to list and close
        app.navigationBars.buttons.firstMatch.tap()
        app.buttons["notes-close-button"].tap()
        XCTAssertTrue(app.buttons["notes-pill-button"].waitForExistence(timeout: 3))
    }

    // MARK: - Notes: new note cursor focus

    /// Creating a new note must place the cursor in the body, not the title.
    @MainActor
    func testNotes_newNote_cursorInBody() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons["notes-new-button"].waitForExistence(timeout: 3)
        app.buttons["notes-new-button"].tap()
        // Body text editor must be the focused element
        let bodyEditor = app.textViews["note-body-editor"]
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 3), "Body editor must exist")
        XCTAssertTrue(bodyEditor.value(forKey: "hasKeyboardFocus") as? Bool ?? false,
                      "Keyboard focus must start in the body, not the title")
    }

    /// Opening an existing note must NOT auto-focus either field.
    @MainActor
    func testNotes_existingNote_noAutoFocus() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons["notes-new-button"].waitForExistence(timeout: 3)
        // Create a note with a title so it's "existing"
        app.buttons["notes-new-button"].tap()
        let titleField = app.textFields["note-title-field"]
        _ = titleField.waitForExistence(timeout: 3)
        titleField.tap()
        titleField.typeText("Test Note")
        app.navigationBars.buttons.firstMatch.tap()
        // Re-open the note
        app.cells.firstMatch.tap()
        // Body should NOT be auto-focused (keyboard should not appear unbidden)
        let bodyEditor = app.textViews["note-body-editor"]
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 3))
        XCTAssertFalse(bodyEditor.value(forKey: "hasKeyboardFocus") as? Bool ?? false,
                       "Existing notes must not auto-focus the body on open")
    }

    // MARK: - Note editor: Done button

    /// Done button must exist in the note editor toolbar.
    @MainActor
    func testNoteEditor_hasDoneButton() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons["notes-new-button"].waitForExistence(timeout: 3)
        app.buttons["notes-new-button"].tap()
        XCTAssertTrue(
            app.buttons["note-done-button"].waitForExistence(timeout: 3),
            "Done button must exist in the note editor toolbar"
        )
    }

    /// Tapping Done in the note editor must dismiss the keyboard.
    @MainActor
    func testNoteEditor_doneButtonDismissesKeyboard() throws {
        let app = launchApp()
        openNotes(in: app)
        _ = app.buttons["notes-new-button"].waitForExistence(timeout: 3)
        app.buttons["notes-new-button"].tap()
        // Keyboard should be visible (body auto-focused on new note)
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3), "Keyboard must appear on new note")
        app.buttons["note-done-button"].tap()
        // Keyboard must be gone after tapping Done
        XCTAssertFalse(app.keyboards.firstMatch.exists, "Keyboard must be dismissed after tapping Done")
    }

    // MARK: - Settings: Focus Mode removed

    /// Settings must not show a Focus Mode section.
    @MainActor
    func testSettings_noFocusModeSection() throws {
        let app = launchApp()
        app.buttons["settings-gear-button"].tap()
        _ = app.navigationBars["Settings"].waitForExistence(timeout: 3)
        XCTAssertFalse(
            app.staticTexts["Focus Mode"].exists,
            "Focus Mode section must not appear in Settings"
        )
    }

    /// Settings must still show Prayer Audio and Interruptions sections.
    @MainActor
    func testSettings_requiredSectionsExist() throws {
        let app = launchApp()
        app.buttons["settings-gear-button"].tap()
        _ = app.navigationBars["Settings"].waitForExistence(timeout: 3)
        XCTAssertTrue(app.staticTexts["Prayer Audio"].exists, "Prayer Audio section must exist")
        XCTAssertTrue(app.staticTexts["Interruptions"].exists, "Interruptions section must exist")
    }

    // MARK: - Onboarding layout: small device (iPhone 16e)

    /// Helper — launches the app at onboarding screen 1 on a small device.
    /// The destination is fixed at runtime by the test scheme; this just marks intent.
    @MainActor
    private func launchOnboarding() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-UITesting", "-hasCompletedOnboarding", "0"]
        app.launch()
        return app
    }

    /// Screen 1: CTA button must be hittable (not clipped off the bottom) on small screens.
    @MainActor
    func testWelcome_ctaHittableOnSmallDevice() throws {
        let app = launchOnboarding()
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Continue'")).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 3), "CTA button must exist on welcome screen")
        XCTAssertTrue(cta.isHittable, "CTA button must be fully visible and tappable on small screens")
    }

    /// Screen 1: all three feature rows must be visible and hittable on small screens.
    @MainActor
    func testWelcome_allFeatureRowsVisibleOnSmallDevice() throws {
        let app = launchOnboarding()
        _ = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Continue'")).firstMatch.waitForExistence(timeout: 3)
        for label in ["Pray without distractions", "Bible", "Notes"] {
            XCTAssertTrue(
                app.staticTexts[label].exists,
                "Feature row '\(label)' must be visible on small screens"
            )
        }
    }

    /// Screen 2: CTA button must be hittable on small screens.
    @MainActor
    func testSilence_ctaHittableOnSmallDevice() throws {
        let app = launchOnboarding()
        // Advance to screen 2
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Continue'")).firstMatch.tap()
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Open Settings'")).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 3), "CTA must exist on silence screen")
        XCTAssertTrue(cta.isHittable, "CTA button must be fully visible and tappable on small screens")
    }

    /// Screen 2: all four step rows must be visible on small screens.
    @MainActor
    func testSilence_allStepRowsVisibleOnSmallDevice() throws {
        let app = launchOnboarding()
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Continue'")).firstMatch.tap()
        _ = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Open Settings'")).firstMatch.waitForExistence(timeout: 3)
        for label in ["Open Settings", "Choose a Focus", "Set a schedule", "Add Holystening"] {
            XCTAssertTrue(
                app.staticTexts[label].exists,
                "Step '\(label)' must be visible on small screens"
            )
        }
    }

    /// Screen 3: CTA button must be hittable on small screens.
    @MainActor
    func testCongrats_ctaHittableOnSmallDevice() throws {
        let app = launchOnboarding()
        // Advance through screens 1 and 2
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Continue'")).firstMatch.tap()
        let openSettings = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Open Settings'")).firstMatch
        XCTAssertTrue(openSettings.waitForExistence(timeout: 3))
        openSettings.tap()
        let done = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Done'")).firstMatch
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        done.tap()
        let startCTA = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Start'")).firstMatch
        XCTAssertTrue(startCTA.waitForExistence(timeout: 3), "Start CTA must exist on congrats screen")
        XCTAssertTrue(startCTA.isHittable, "Start CTA must be fully visible and tappable on small screens")
    }

    // MARK: - Onboarding layout: regression on large device (iPhone 17 Pro)

    /// Screen 1: CTA and all feature rows must remain hittable on large screens too.
    @MainActor
    func testWelcome_layoutRegressionOnLargeDevice() throws {
        let app = launchOnboarding()
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Continue'")).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 3))
        XCTAssertTrue(cta.isHittable, "CTA must remain hittable on large device after layout changes")
        for label in ["Pray without distractions", "Bible", "Notes"] {
            XCTAssertTrue(app.staticTexts[label].exists, "'\(label)' must remain visible on large device")
        }
    }

    /// Screen 2: CTA and all step rows must remain hittable on large screens too.
    @MainActor
    func testSilence_layoutRegressionOnLargeDevice() throws {
        let app = launchOnboarding()
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Continue'")).firstMatch.tap()
        let cta = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Open Settings'")).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 3))
        XCTAssertTrue(cta.isHittable, "CTA must remain hittable on large device after layout changes")
        for label in ["Open Settings", "Choose a Focus", "Set a schedule", "Add Holystening"] {
            XCTAssertTrue(app.staticTexts[label].exists, "'\(label)' must remain visible on large device")
        }
    }

    // MARK: - Launch performance

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
