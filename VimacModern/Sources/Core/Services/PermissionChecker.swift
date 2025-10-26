//
//  PermissionChecker.swift
//  VimacModern
//
//  Accessibility permission checking
//

import Cocoa
import ApplicationServices

enum PermissionChecker {
    /// Check if accessibility permission is granted
    static func hasAccessibilityPermission() -> Bool {
        return AXIsProcessTrusted()
    }

    /// Request accessibility permission (opens System Settings)
    static func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    /// Check if Input Monitoring permission is granted
    static func hasInputMonitoringPermission() -> Bool {
        // Check by attempting to create an event tap
        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: { _, _, event, _ in return Unmanaged.passRetained(event) },
            userInfo: nil
        ) else {
            return false
        }

        // Clean up
        CFMachPortInvalidate(tap)
        return true
    }
}
