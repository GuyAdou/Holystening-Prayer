import SwiftUI

enum AppColors {

    // MARK: - Base palette
    static let navy     = Color(hex: "1a1a2e")
    static let navyMid  = Color(hex: "16213e")
    static let navyDeep = Color(hex: "0f3460")
    static let teal     = Color(hex: "a8edea")
    static let pink     = Color(hex: "fed6e3")
    static let gold     = Color(hex: "d4af37")

    // MARK: - CTA & interaction buttons
    static var ctaButton = featureIcon  // primary action buttons (onboarding, fix interruptions)
    static let ctaButtonShadow = teal                 // glow/shadow on CTA press

    // MARK: - Feature icon gradient (onboarding welcome rows)
    static var featureIcon: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "d4af37"), Color(hex: "E8CC82"), Color(hex: "FAE8A8")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Bible accent
    static let bibleGold = Color(hex: "C9A84C")

    // MARK: - Neutrals
    /// A soft off-black, not pure #000000, for the first onboarding screen.
    static let offBlack = Color(hex: "4C6275")

    // MARK: - Logo-derived tones
    /// Sampled from the cloudy sky background of the dove logo/app icon.
    static let cloudyBlue      = Color(hex: "0c2746")
    /// cloudyBlueMid base, tilted warm toward the dove's golden-white glow.
    static let cloudyBlueMid   = Color(hex: "989785")
    static let cloudyBlueLight = Color(hex: "A8AEB4")  // cloudyBlue blended 50% toward white

    // MARK: - Session / prayer gradients
    static var sessionBackground: LinearGradient {
        LinearGradient(
            colors: [navy, navyMid, navyDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Same diagonal 3-stop structure as sessionBackground, but in the
    /// lighter cloudyBlue family, so starting a session is a visible
    /// transition from this into the much darker sessionBackground.
    static var cloudyBackground: LinearGradient {
        LinearGradient(
            colors: [cloudyBlue, cloudyBlueMid],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accent: LinearGradient {
        LinearGradient(
            colors: [teal, pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentHorizontal: LinearGradient {
        LinearGradient(
            colors: [teal, pink],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var buttonInactive: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "e8e8e8"), Color(hex: "d0d0d0")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Hex initialiser

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8)  & 0xFF) / 255
        let b = Double( rgb        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
