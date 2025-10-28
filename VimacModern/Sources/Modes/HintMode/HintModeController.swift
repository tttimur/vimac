//
//  HintModeController.swift
//  VimacModern
//
//  Controls hint mode lifecycle: query elements, display hints, handle input
//  Uses Combine instead of RxSwift
//

import Cocoa
import Combine

/// Action to perform when hint is selected
enum HintAction {
    case leftClick
    case rightClick
    case doubleClick
    case hover
}

/// Controller for hint mode
class HintModeController {
    // MARK: - Properties

    private let app: NSRunningApplication
    private let window: Element
    private let overlayWindow: OverlayWindow
    private let hintCharacters: String

    private var hints: [Hint] = []
    private var hintViews: [HintView] = []
    private var typedText: String = ""
    private var eventTap: EventTap?
    private var cancellables = Set<AnyCancellable>()

    // Callbacks
    var onDeactivate: (() -> Void)?
    var onHintSelected: ((Hint, HintAction) -> Void)?

    // MARK: - Initialization

    init(
        app: NSRunningApplication,
        window: Element,
        overlayWindow: OverlayWindow,
        hintCharacters: String = "sadfjklewcmpgh"
    ) {
        self.app = app
        self.window = window
        self.overlayWindow = overlayWindow
        self.hintCharacters = hintCharacters
    }

    // MARK: - Activation

    /// Activate hint mode
    func activate() {
        print("🎯 Activating hint mode...")

        // Hide cursor
        MouseActions.hideCursor()

        // Query elements in background
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }

            let elements = self.queryElements()
            print("Found \(elements.count) hintable elements")

            // Generate hints
            let hints = HintPositioning.generateHints(for: elements, hintCharacters: self.hintCharacters)

            DispatchQueue.main.async {
                self.displayHints(hints)
                self.startListening()
            }
        }
    }

    /// Deactivate hint mode
    func deactivate() {
        print("👋 Deactivating hint mode...")

        // Show cursor
        MouseActions.showCursor()

        // Stop listening
        eventTap?.disable()
        eventTap = nil

        // Hide overlay
        overlayWindow.orderOut(nil)

        // Clear state
        hints.removeAll()
        hintViews.removeAll()
        typedText = ""

        // Notify
        onDeactivate?()
    }

    // MARK: - Element Query

    private func queryElements() -> [Element] {
        let service = QueryWindowService(app: app, window: window)
        return service.perform()
    }

    // MARK: - Display

    private func displayHints(_ hints: [Hint]) {
        self.hints = hints

        // Create container view
        let container = NSView(frame: overlayWindow.frame)

        // Create hint views
        for hint in hints {
            let hintView = HintView(element: hint.element, text: hint.text, typedText: typedText, fontSize: 11)

            // Position the hint
            let globalPosition = HintPositioning.convertToScreenCoordinates(CGRect(origin: hint.position, size: .zero)).origin

            // Convert to window coordinates
            let windowPosition = container.convert(globalPosition, from: nil)
            hintView.frame = CGRect(origin: windowPosition, size: hintView.intrinsicContentSize)

            container.addSubview(hintView)
            hintViews.append(hintView)
        }

        // Show overlay
        overlayWindow.contentView = container
        overlayWindow.coverAllScreens()
        overlayWindow.orderFrontRegardless()
        overlayWindow.makeKey()
    }

    // MARK: - Input Handling

    private func startListening() {
        eventTap = EventTap(eventMask: .allKeyboard) { [weak self] event in
            return self?.handleKeyEvent(event)
        }
        eventTap?.enable()
    }

    private func handleKeyEvent(_ event: CGEvent) -> CGEvent? {
        guard let nsEvent = NSEvent(cgEvent: event) else { return event }

        // Only handle key down
        guard event.type == .keyDown else { return event }

        // Escape key - cancel
        if nsEvent.keyCode == 53 { // Escape
            deactivate()
            return nil
        }

        // Backspace - delete character
        if nsEvent.keyCode == 51 { // Backspace
            if !typedText.isEmpty {
                typedText.removeLast()
                updateHintViews()
            }
            return nil
        }

        // Get character
        guard let char = nsEvent.charactersIgnoringModifiers?.lowercased().first else {
            return event
        }

        // Check if character is valid hint character
        guard hintCharacters.contains(char) else {
            return event // Pass through non-hint characters
        }

        // Add character
        typedText.append(char)
        updateHintViews()

        // Check for match
        if let matchedHint = findMatchingHint() {
            handleHintMatch(matchedHint, modifiers: nsEvent.modifierFlags)
        }

        return nil // Consume event
    }

    private func updateHintViews() {
        for (index, hint) in hints.enumerated() {
            if index < hintViews.count {
                hintViews[index].updateTypedText(typedText)
            }
        }
    }

    private func findMatchingHint() -> Hint? {
        return hints.first { hint in
            hint.text.lowercased() == typedText.lowercased()
        }
    }

    private func handleHintMatch(_ hint: Hint, modifiers: NSEvent.ModifierFlags) {
        // Determine action based on modifiers
        let action: HintAction
        if modifiers.contains(.control) {
            action = .rightClick
        } else if modifiers.contains(.shift) {
            action = .doubleClick
        } else if modifiers.contains(.option) {
            action = .hover
        } else {
            action = .leftClick
        }

        // Perform action
        performAction(action, on: hint)

        // Deactivate
        deactivate()
    }

    private func performAction(_ action: HintAction, on hint: Hint) {
        let position = hint.position

        switch action {
        case .leftClick:
            MouseActions.leftClick(at: position)

        case .rightClick:
            MouseActions.rightClick(at: position)

        case .doubleClick:
            MouseActions.doubleClick(at: position)

        case .hover:
            MouseActions.moveMouse(to: position)
        }

        // Notify
        onHintSelected?(hint, action)
    }
}
