//
//  LaunchAtLogin.swift
//  VimacModern
//
//  Native launch-at-login using ServiceManagement
//  Replaces LaunchAtLogin Carthage dependency
//  macOS 13+ uses SMAppService API
//

import Cocoa
import ServiceManagement

/// Manages launch-at-login functionality
@available(macOS 13.0, *)
enum LaunchAtLogin {
    private static let service = SMAppService.mainApp

    /// Check if app is set to launch at login
    static var isEnabled: Bool {
        return service.status == .enabled
    }

    /// Enable launch at login
    /// - Throws: Error if registration fails
    static func enable() throws {
        guard service.status != .enabled else { return }
        try service.register()
    }

    /// Disable launch at login
    /// - Throws: Error if unregistration fails
    static func disable() throws {
        guard service.status == .enabled else { return }
        try service.unregister()
    }

    /// Toggle launch at login
    /// - Throws: Error if registration/unregistration fails
    static func toggle() throws {
        if isEnabled {
            try disable()
        } else {
            try enable()
        }
    }

    /// Get current status
    static var status: SMAppService.Status {
        return service.status
    }
}

// MARK: - Legacy Support (macOS 10.14 - 12.x)

/// Legacy launch-at-login for older macOS versions
/// Uses deprecated SMLoginItemSetEnabled
@available(macOS, deprecated: 13.0, message: "Use LaunchAtLogin (SMAppService) for macOS 13+")
enum LegacyLaunchAtLogin {
    private static let bundleID = Bundle.main.bundleIdentifier ?? "com.vimac.modern"

    static var isEnabled: Bool {
        // Check if login item exists
        guard let jobDict = SMCopyAllJobDictionaries(kSMDomainUserLaunchd)?.takeRetainedValue() as? [[String: Any]] else {
            return false
        }

        return jobDict.contains { dict in
            dict["Label"] as? String == bundleID
        }
    }

    static func setEnabled(_ enabled: Bool) -> Bool {
        return SMLoginItemSetEnabled(bundleID as CFString, enabled)
    }
}

// MARK: - Universal Interface

/// Universal launch-at-login API that works across macOS versions
enum UniversalLaunchAtLogin {
    static var isEnabled: Bool {
        if #available(macOS 13.0, *) {
            return LaunchAtLogin.isEnabled
        } else {
            return LegacyLaunchAtLogin.isEnabled
        }
    }

    static func setEnabled(_ enabled: Bool) throws {
        if #available(macOS 13.0, *) {
            if enabled {
                try LaunchAtLogin.enable()
            } else {
                try LaunchAtLogin.disable()
            }
        } else {
            let success = LegacyLaunchAtLogin.setEnabled(enabled)
            if !success {
                throw NSError(
                    domain: "com.vimac.modern.launchatlogin",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to set launch at login"]
                )
            }
        }
    }

    static func toggle() throws {
        try setEnabled(!isEnabled)
    }
}
