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

**Settings**
- Choose your prayer audio track
- Choose which Focus mode to activate

---

## Architecture

Built with SwiftUI, following MVVM.

```
Holystening/
├── Models/
│   ├── PrayerSession.swift     # PrayerTrack and AppSettings models
│   └── AppConfig.swift         # All configurable constants (timeouts, tracks, focus modes)
├── ViewModels/
│   └── PrayerViewModel.swift   # Session state, coordinates audio + focus
├── Views/
│   ├── HomeView.swift          # Main UI, idle/ambient mode logic
│   └── SettingsView.swift      # Track and Focus mode picker
├── Services/
│   ├── AudioService.swift      # AVAudioPlayer wrapper, fade out, interruption handling
│   └── FocusService.swift      # iOS Focus Mode + AppIntents filter registration
PrayerWidget/
│   └── PrayerWidget.swift      # 3 widget variants, deep links to prayerapp://start
```

---

## Stack

| Layer | Tool |
|---|---|
| UI | SwiftUI |
| Audio | AVFoundation |
| Widgets | WidgetKit |
| Focus integration | AppIntents |
| Architecture | MVVM |

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

## Status

Currently in development — App Store release pending.
