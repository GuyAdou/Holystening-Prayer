# Holystening — Prayer App

An iOS app for focused prayer sessions. Tap to start, it plays ambient prayer audio, silences your notifications via iOS Focus Mode, and dims the screen so nothing pulls you away.
<p align="center">
  <img width="503" height="471" alt="image" src="https://github.com/user-attachments/assets/f220d47d-45f9-4d01-8c09-56884cfa519a" />
</p>


---

## Features

**Prayer session**
- One-tap start/stop with an animated play button
- Audio progress bar and loop toggle
- Screen auto-dims after 8 seconds of inactivity — tap anywhere to wake
- Audio fades out smoothly when the session ends

**Focus Mode integration**
- Activates your chosen iOS Focus (Do Not Disturb, Sleep, Personal, etc.) when prayer begins
- Deactivates automatically when the session ends or the track finishes
- Keeps the screen on for the full session (`isIdleTimerDisabled`)

**Home screen widgets**
- 3 widget styles (Blue, Golden, Warm) in small and medium sizes
- Tap the widget to launch directly into a prayer session via deep link

**Bible**
- Read Scripture during a prayer session or from the home screen
- King James Version, chapter-by-chapter navigation
- Opens as a sheet without interrupting the session

**Notes**
- Jot down thoughts while praying — notes auto-save continuously
- Full list view with last-modified sorting, swipe-to-delete
- Pencil / drawing canvas toggle inside the editor

**Onboarding**
- 3-screen flow: welcome → silence setup → congrats
- Guides the user to configure an iOS Focus filter for the app
- Skipped automatically on subsequent launches

**Settings**
- Choose your prayer audio track
- Choose which Apple Focus mode to activate during prayer

---

## Testing

25 UI tests covering:

- Bible sheet (opens from home pill, opens during prayer, chapter nav, KJV footnote, dismiss keeps session active)
- Pill visibility (Notes + Bible always present, including during active session)
- Notes (Close button, new-note auto-focus, Done button dismisses keyboard, existing note no auto-focus)
- Settings (required sections present, no stale "Focus Mode" label)
- Onboarding layout (CTAs hittable on small devices, all content rows visible)

Run with:

```
xcodebuild -project Holystening.xcodeproj -scheme Holystening \
  -destination 'platform=iOS Simulator,name=iPhone 16e' test
```

---

## Architecture

Built with SwiftUI, following MVVM.

```
Holystening/
├── Models/
│   ├── PrayerSession.swift     # PrayerTrack and AppSettings models
│   ├── AppColors.swift         # Shared Color(hex:) extension and palette
│   ├── AppConfig.swift         # All configurable constants (timeouts, tracks, focus modes)
│   └── Note.swift              # SwiftData Note model
├── ViewModels/
│   └── PrayerViewModel.swift   # Session state, coordinates audio + focus
├── Views/
│   ├── HomeView.swift          # Main UI, pill buttons, idle/ambient mode logic
│   ├── SettingsView.swift      # Track and Focus mode picker
│   ├── Bible/
│   │   └── BibleView.swift     # KJV reader, chapter navigation
│   ├── Notes/
│   │   ├── NotesView.swift     # Note list with SwiftData @Query
│   │   └── NoteEditorView.swift# Text + drawing canvas editor
│   └── Onboarding/
│       ├── OnboardingWelcomeView.swift
│       ├── OnboardingSilenceView.swift
│       └── OnboardingCongratsView.swift
├── Services/
│   ├── AudioService.swift      # AVAudioPlayer wrapper, fade out, interruption handling
│   └── FocusService.swift      # iOS Focus Mode + AppIntents filter registration
PrayerWidget/
│   └── PrayerWidget.swift      # 3 widget variants, deep links to prayerapp://start
HstningUITests/
│   └── HstningUITests.swift    # 25 UI tests
```

---

## Adding audio tracks

Audio files are not included in the repo. To add your own:

1. Drag your MP3 into the `Holystening/` folder in Xcode (check "Copy items if needed")
2. Register it in `AppConfig.swift`:

```swift
static let tracks: [PrayerTrack] = [
    PrayerTrack(name: "Your Track Name", fileName: "your-file-name", fileExtension: "mp3"),
]
```

---

## Stack

| Layer | Tool |
|---|---|
| UI | SwiftUI |
| Audio | AVFoundation |
| Persistence | SwiftData |
| Widgets | WidgetKit |
| Focus integration | AppIntents |
| Architecture | MVVM |

---

## Status

Currently in development — App Store release pending.
