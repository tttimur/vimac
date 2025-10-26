//
//  VimacApp.swift
//  VimacModern
//
//  Main app entry point
//  Zero external dependencies!
//

import Cocoa
import Combine

@main
class VimacApp: NSApplication, NSApplicationDelegate {
    // MARK: - Services

    private var appService: FrontmostApplicationService?
    private var overlayWindow: OverlayWindow?
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

        // Check accessibility permission
        guard PermissionChecker.hasAccessibilityPermission() else {
            showPermissionAlert()
            return
        }

        // Initialize services
        setupServices()

        print("✅ VimacModern ready!")
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

        // Observe app changes
        appService?.frontmostAppPublisher
            .sink { app in
                print("Frontmost app: \(app?.localizedName ?? "none")")
            }
            .store(in: &cancellables)

        // Setup key sequence listener (example: "fd" and "jk")
        keySequenceListener = KeySequenceListener(
            sequences: [
                Array("fd"), // Hint mode trigger
                Array("jk")  // Alternative trigger
            ],
            resetDelay: 0.25
        )

        keySequenceListener?.matchPublisher
            .sink { [weak self] sequence in
                let str = String(sequence)
                print("Key sequence matched: \(str)")
                self?.onKeySequenceMatched(str)
            }
            .store(in: &cancellables)

        keySequenceListener?.start()
    }

    private func onKeySequenceMatched(_ sequence: String) {
        // TODO: Activate hint mode
        print("🎯 Activating hint mode...")

        // Demo: Show overlay window with test hints
        showDemoHints()
    }

    // MARK: - Demo

    private func showDemoHints() {
        guard let window = overlayWindow else { return }

        // Create container view
        let container = NSView(frame: NSScreen.main?.frame ?? .zero)

        // Create demo hints with Tokyo Night styling
        let hints = [
            ("SA", CGPoint(x: 100, y: 100)),
            ("DF", CGPoint(x: 200, y: 150)),
            ("JK", CGPoint(x: 300, y: 200)),
            ("LE", CGPoint(x: 400, y: 250))
        ]

        for (text, position) in hints {
            // Create a dummy element for demo
            let dummyElement = Element(
                rawElement: AXUIElementCreateSystemWide(),
                frame: CGRect(origin: position, size: CGSize(width: 50, height: 30)),
                actions: [],
                role: "AXButton"
            )

            let hintView = HintView(element: dummyElement, text: text, fontSize: 11)
            hintView.frame = CGRect(origin: position, size: hintView.intrinsicContentSize)
            container.addSubview(hintView)
        }

        window.contentView = container
        window.coverAllScreens()
        window.orderFrontRegardless()
        window.makeKey()

        // Hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            window.orderOut(nil)
        }
    }

    // MARK: - Permissions

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "VimacModern needs accessibility permission to function. Please grant permission in System Settings."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Quit")

        if alert.runModal() == .alertFirstButtonReturn {
            PermissionChecker.requestAccessibilityPermission()
        }

        NSApplication.shared.terminate(nil)
    }
}
