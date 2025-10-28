//
//  TokyoNightTheme.swift
//  VimacModern
//
//  Tokyo Night color palette for futuristic Evangelion-inspired UI
//

import Cocoa

/// Tokyo Night color palette
enum TokyoNightTheme {
    // MARK: - Background Colors

    /// Main hint background - Light blue (#7aa2f7)
    static let hintBackground = NSColor(red: 0x7a / 255.0, green: 0xa2 / 255.0, blue: 0xf7 / 255.0, alpha: 1.0)

    /// Alternative hint background - Purple (#bb9af7)
    static let hintBackgroundAlt = NSColor(red: 0xbb / 255.0, green: 0x9a / 255.0, blue: 0xf7 / 255.0, alpha: 1.0)

    // MARK: - Text Colors

    /// Untyped hint text - Dark for contrast (#1a1b26)
    static let hintTextUntyped = NSColor(red: 0x1a / 255.0, green: 0x1b / 255.0, blue: 0x26 / 255.0, alpha: 1.0)

    /// Typed hint text - Orange highlight (#ff9e64)
    static let hintTextTyped = NSColor(red: 0xff / 255.0, green: 0x9e / 255.0, blue: 0x64 / 255.0, alpha: 1.0)

    // MARK: - Border & Accents

    /// Border color - Blue-gray (#565f89)
    static let border = NSColor(red: 0x56 / 255.0, green: 0x5f / 255.0, blue: 0x89 / 255.0, alpha: 1.0)

    /// Glow color - Cyan (#7dcfff) - for optional futuristic glow
    static let glow = NSColor(red: 0x7d / 255.0, green: 0xcf / 255.0, blue: 0xff / 255.0, alpha: 0.3)

    // MARK: - UI Elements

    /// Scroll indicator - Red (#f7768e)
    static let scrollIndicator = NSColor(red: 0xf7 / 255.0, green: 0x76 / 255.0, blue: 0x8e / 255.0, alpha: 1.0)

    /// Success flash - Green (#9ece6a)
    static let success = NSColor(red: 0x9e / 255.0, green: 0xce / 255.0, blue: 0x6a / 255.0, alpha: 1.0)
}

// MARK: - NSColor Hex Convenience

extension NSColor {
    /// Create color from hex string (e.g., "7aa2f7")
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
}
