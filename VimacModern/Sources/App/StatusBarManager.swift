//
//  StatusBarManager.swift
//  VimacModern
//
//  Menu bar integration
//

import Cocoa
import SwiftUI

/// Manages the menu bar status item
class StatusBarManager {
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?

    init() {
        setupStatusItem()
    }

    private func setupStatusItem() {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else { return }

        // Set icon (use SF Symbol)
        let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "VimacModern")?
            .withSymbolConfiguration(config)

        // Create menu
        let menu = NSMenu()

        // Hint Mode
        let hintModeItem = NSMenuItem(
            title: "Activate Hint Mode",
            action: #selector(activateHintMode),
            keyEquivalent: ""
        )
        hintModeItem.target = self
        menu.addItem(hintModeItem)

        // Scroll Mode
        let scrollModeItem = NSMenuItem(
            title: "Activate Scroll Mode",
            action: #selector(activateScrollMode),
            keyEquivalent: ""
        )
        scrollModeItem.target = self
        menu.addItem(scrollModeItem)

        menu.addItem(NSMenuItem.separator())

        // Settings
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // About
        let aboutItem = NSMenuItem(
            title: "About VimacModern",
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func activateHintMode() {
        NotificationCenter.default.post(name: .activateHintMode, object: nil)
    }

    @objc private func activateScrollMode() {
        NotificationCenter.default.post(name: .activateScrollMode, object: nil)
    }

    @objc private func openSettings() {
        showSettingsWindow()
    }

    @objc private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    // MARK: - Settings Window

    private func showSettingsWindow() {
        if settingsWindow == nil {
            // Create SwiftUI settings window
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "VimacModern Settings"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.setContentSize(NSSize(width: 500, height: 400))
            window.center()

            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let activateHintMode = Notification.Name("activateHintMode")
    static let activateScrollMode = Notification.Name("activateScrollMode")
}
