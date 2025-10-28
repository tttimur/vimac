//
//  ModeCoordinator.swift
//  VimacModern
//
//  Coordinates between hint mode and scroll mode
//

import Cocoa
import Combine

/// Coordinates mode activation and switching
class ModeCoordinator {
    // MARK: - Properties

    private let overlayWindow: OverlayWindow
    private let appService: FrontmostApplicationService
    private var cancellables = Set<AnyCancellable>()

    // Current state
    private var currentMode: Mode?
    private var currentApp: NSRunningApplication?
    private var currentWindow: Element?

    // Controllers
    private var hintModeController: HintModeController?
    private var scrollModeController: ScrollModeController?

    // Settings
    @AppStorage("hintCharacters") private var hintCharacters = "sadfjklewcmpgh"
    @AppStorage("scrollSensitivity") private var scrollSensitivity = 20
    @AppStorage("reverseHorizontal") private var reverseHorizontal = false
    @AppStorage("reverseVertical") private var reverseVertical = false

    enum Mode {
        case hint
        case scroll
    }

    // MARK: - Initialization

    init(overlayWindow: OverlayWindow, appService: FrontmostApplicationService) {
        self.overlayWindow = overlayWindow
        self.appService = appService

        setupObservers()
    }

    private func setupObservers() {
        // Observe app changes
        appService.frontmostAppPublisher
            .sink { [weak self] app in
                self?.currentApp = app
                self?.onAppChanged()
            }
            .store(in: &cancellables)

        // Observe window changes
        appService.focusedWindowPublisher
            .sink { [weak self] window in
                self?.currentWindow = window
                self?.onWindowChanged()
            }
            .store(in: &cancellables)

        // Observe mode activation requests
        NotificationCenter.default.publisher(for: .activateHintMode)
            .sink { [weak self] _ in
                self?.activateHintMode()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .activateScrollMode)
            .sink { [weak self] _ in
                self?.activateScrollMode()
            }
            .store(in: &cancellables)
    }

    // MARK: - Mode Activation

    func activateHintMode() {
        guard let app = currentApp, let window = currentWindow else {
            print("⚠️ No active app or window")
            return
        }

        // Deactivate current mode
        deactivateCurrentMode()

        // Create and activate hint mode
        let controller = HintModeController(
            app: app,
            window: window,
            overlayWindow: overlayWindow,
            hintCharacters: hintCharacters
        )

        controller.onDeactivate = { [weak self] in
            self?.currentMode = nil
            self?.hintModeController = nil
        }

        controller.activate()

        currentMode = .hint
        hintModeController = controller
    }

    func activateScrollMode() {
        guard currentWindow != nil else {
            print("⚠️ No active window")
            return
        }

        // Deactivate current mode
        deactivateCurrentMode()

        // Create and activate scroll mode
        let controller = ScrollModeController(
            window: currentWindow!,
            overlayWindow: overlayWindow,
            sensitivity: scrollSensitivity,
            reverseHorizontal: reverseHorizontal,
            reverseVertical: reverseVertical
        )

        controller.onDeactivate = { [weak self] in
            self?.currentMode = nil
            self?.scrollModeController = nil
        }

        controller.activate()

        currentMode = .scroll
        scrollModeController = controller
    }

    func deactivateCurrentMode() {
        hintModeController?.deactivate()
        scrollModeController?.deactivate()

        hintModeController = nil
        scrollModeController = nil
        currentMode = nil
    }

    // MARK: - Event Handlers

    private func onAppChanged() {
        // Deactivate mode when app changes
        if currentMode != nil {
            deactivateCurrentMode()
        }
    }

    private func onWindowChanged() {
        // Deactivate mode when window changes
        if currentMode != nil {
            deactivateCurrentMode()
        }
    }
}

// MARK: - AppStorage Convenience

@propertyWrapper
struct AppStorage<Value> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get {
            UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    init(wrappedValue: Value, _ key: String) {
        self.key = key
        self.defaultValue = wrappedValue
    }
}
