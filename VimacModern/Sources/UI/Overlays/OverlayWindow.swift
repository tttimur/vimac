//
//  OverlayWindow.swift
//  VimacModern
//
//  Transparent overlay window for hints
//  Pure AppKit, no dependencies
//

import Cocoa

/// Transparent, non-activating window for displaying hints
class OverlayWindow: NSPanel {
    init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        // Transparent background
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false

        // Don't intercept mouse events
        self.ignoresMouseEvents = true

        // Window level and behavior
        self.level = .statusBar // Above most windows but below menu bar
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Allow the window to become key (for keyboard events if needed)
        self.isMovableByWindowBackground = false
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return false
    }

    /// Position window to cover the entire screen
    func coverScreen(_ screen: NSScreen) {
        self.setFrame(screen.frame, display: true)
    }

    /// Position window to cover all screens
    func coverAllScreens() {
        guard let mainScreen = NSScreen.main else { return }

        var totalFrame = mainScreen.frame

        for screen in NSScreen.screens {
            totalFrame = totalFrame.union(screen.frame)
        }

        self.setFrame(totalFrame, display: true)
    }
}
