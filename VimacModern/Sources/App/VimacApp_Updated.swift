//
//  VimacApp.swift
//  VimacModern
//
//  Main app entry point - fully integrated
//  Zero external dependencies!
//

import Cocoa
import Combine

@main
class VimacApp: NSApplication, NSApplicationDelegate {
    // MARK: - Services

    private var appService: FrontmostApplicationService?
    private var overlayWindow: OverlayWindow?
    private var modeCoordinator: ModeCoordinator?
    private var statusBarManager: StatusBarManager?
    private var keySequenceListener: KeySequenceListener?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    required override init() {
        super.init()
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 VimacModern starting...")
        print("   Zero dependencies ✨")
        print("   Tokyo Night theme 🎨")
        print("   Native frameworks only ⚡")

        // Check accessibility permission
        guard PermissionChecker.hasAccessibilityPermission() else {
            showPermissionAlert()
            return
        }

        // Initialize services
        setupServices()

        print("✅ VimacModern ready!")
        print("   Press 'fd' for Hint Mode")
        print("   Press 'jk' for Scroll Mode")
    }

    func applicationWillTerminate(_ notification: Notification) {
        print("👋 VimacModern shutting down...")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Run in background
    }

    // MARK: - Setup

    private func setupServices() {
        // Create overlay window
        overlayWindow = OverlayWindow()

        // Create frontmost app service
        appService = FrontmostApplicationService()

        guard let overlayWindow = overlayWindow, let appService = appService else {
            print("⚠️ Failed to create core services")
            return
        }

        // Create mode coordinator
        modeCoordinator = ModeCoordinator(overlayWindow: overlayWindow, appService: appService)

        // Create status bar
        statusBarManager = StatusBarManager()

        // Setup key sequence listeners
        setupKeySequenceListeners()

        // Log app changes (optional)
        appService.frontmostAppPublisher
            .sink { app in
                if let app = app {
                    print("📱 Frontmost app: \(app.localizedName ?? "Unknown")")
                }
            }
            .store(in: &cancellables)
    }

    private func setupKeySequenceListeners() {
        // Read shortcuts from UserDefaults
        let hintShortcut = UserDefaults.standard.string(forKey: "hintModeShortcut") ?? "fd"
        let scrollShortcut = UserDefaults.standard.string(forKey: "scrollModeShortcut") ?? "jk"

        // Create listener
        keySequenceListener = KeySequenceListener(
            sequences: [
                Array(hintShortcut),
                Array(scrollShortcut)
            ],
            resetDelay: 0.25
        )

        // Handle matches
        keySequenceListener?.matchPublisher
            .sink { [weak self] sequence in
                let str = String(sequence)
                print("🎯 Key sequence matched: \(str)")

                if str == hintShortcut {
                    self?.modeCoordinator?.activateHintMode()
                } else if str == scrollShortcut {
                    self?.modeCoordinator?.activateScrollMode()
                }
            }
            .store(in: &cancellables)

        keySequenceListener?.start()
    }

    // MARK: - Permissions

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "VimacModern needs accessibility permission to function.\n\nThis allows the app to:\n• Detect UI elements for hints\n• Send click and scroll events\n• Monitor keyboard input\n\nPlease grant permission in System Settings > Privacy & Security > Accessibility."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Quit")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            PermissionChecker.requestAccessibilityPermission()
            // Poll for permission
            pollForPermission()
        } else {
            NSApplication.shared.terminate(nil)
        }
    }

    private func pollForPermission() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            if PermissionChecker.hasAccessibilityPermission() {
                timer.invalidate()
                print("✅ Permission granted! Initializing...")
                self?.setupServices()
            }
        }
    }
}

// MARK: - Menu Commands

extension VimacApp {
    @objc func showSettingsWindow() {
        statusBarManager?.openSettings()
    }
}
