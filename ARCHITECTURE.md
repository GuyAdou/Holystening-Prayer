# Holystening — App Architecture

```mermaid
graph TB
    subgraph Entry["Entry Point"]
        APP["PrayerApp.swift\n@main"]
    end

    subgraph Onboarding["Onboarding Flow (one-time)"]
        OC["OnboardingContainerView"]
        OW["OnboardingWelcomeView\nScreen 1"]
        OS["OnboardingSilenceView\nScreen 2"]
        OG["OnboardingCongratsView\nScreen 3"]
        OC --> OW --> OS --> OG
    end

    subgraph MainScreen["Main Screen"]
        HV["HomeView"]
        PILL["Pill (glass capsule)\nBible · Notes"]
        GEAR["Settings gear\n(idle only)"]
        HV --> PILL
        HV --> GEAR
    end

    subgraph Sheets["Sheets"]
        BV["BibleView\nKJV · chapter nav\nbible-api.com"]
        NV["NotesView\nNavigationStack\nSwiftData list"]
        NEV["NoteEditorView\nTextField · TextEditor\nDrawingCanvas (PencilKit)\nDone button"]
        SV["SettingsView\nAudio · Interruptions"]
        FIV["FixInterruptionsView"]
        NV -->|NavigationLink| NEV
        SV --> FIV
    end

    subgraph VM["View Model"]
        PVM["PrayerViewModel\nObservableObject\n─────────────\nisSessionActive\nisPaused\nisLooping\nsettings"]
    end

    subgraph Services["Services"]
        AS["AudioService\nAVAudioPlayer\nNow Playing\nRemote Commands\nInterruption handler"]
        FS["FocusService\nSetFocusFilterIntent"]
    end

    subgraph Models["Models & Config"]
        AC["AppConfig\nall constants\nfont sizes · copy\ntimeouts"]
        ACL["AppColors\nall colors\n& gradients"]
        NOTE["Note @Model\ntitle · content\ndrawingData · updatedAt"]
        NF["NoteFolder @Model"]
        PT["PrayerTrack struct"]
        APS["AppSettings struct\nselectedTrackIndex"]
    end

    subgraph Storage["Persistence"]
        SD["SwiftData\nModelContainer"]
        APS_["@AppStorage\nonboarding flags\nautoStartSession"]
        API["bible-api.com\nHTTPS"]
    end

    subgraph Tests["Test Targets"]
        UT["HstningTests\nSwift Testing (unit)\nBibleVersionTests"]
        UI["HstningUITests\nXCUITest · iPhone 16e\nBible · Notes · Pill\nSettings · Onboarding\n25 tests"]
    end

    APP -->|hasCompletedOnboarding = false| OC
    APP -->|hasCompletedOnboarding = true| HV
    APP -->|@EnvironmentObject| PVM
    APP -->|ModelContainer| SD

    PILL -->|sheet| BV
    PILL -->|sheet| NV
    GEAR -->|sheet| SV

    PVM --> AS
    PVM --> FS

    NV <-->|@Query / insert / delete| SD
    SD --> NOTE
    SD --> NF

    BV -->|async fetch| API
    APS_ --> OC
    APS_ --> HV

    PVM --- AC
    HV --- ACL
    BV --- ACL
```

## Layer summary

| Layer | Files | Responsibility |
|---|---|---|
| Entry | `PrayerApp.swift` | App setup, DI, root view gating |
| Onboarding | `Onboarding*View.swift` | One-time 3-step setup flow |
| Main screen | `HomeView.swift` | Prayer session, pill, idle mode |
| Sheets | `BibleView`, `NotesView`, `NoteEditorView`, `SettingsView`, `FixInterruptionsView` | Feature screens |
| ViewModel | `PrayerViewModel.swift` | Session state, coordinates services |
| Services | `AudioService.swift`, `FocusService.swift` | AVAudioPlayer, Focus filter intent |
| Models | `Note`, `NoteFolder`, `PrayerTrack`, `AppSettings` | Data shapes |
| Config | `AppConfig`, `AppColors` | Single source of truth for constants & colors |
| Persistence | SwiftData, `@AppStorage` | Notes on-device, flags in UserDefaults |
| Tests | `HstningTests`, `HstningUITests` | Unit (Swift Testing) + UI (XCUITest) |
