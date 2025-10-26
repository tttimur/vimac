//
//  ScrollModeController.swift
//  VimacModern
//
//  Vim-style scrolling with hjkl keys
//  Pure Swift with Combine
//

import Cocoa
import Combine

/// Controller for scroll mode (vim-style hjkl scrolling)
class ScrollModeController {
    // MARK: - Properties

    private let window: Element
    private let overlayWindow: OverlayWindow
    private let sensitivity: Int
    private let reverseHorizontal: Bool
    private let reverseVertical: Bool

    private var scroller: Scroller?
    private var eventTap: EventTap?
    private var borderView: NSView?

    // Key mappings (default vim: hjkl)
    private let leftKey: String = "h"
    private let downKey: String = "j"
    private let upKey: String = "k"
    private let rightKey: String = "l"

    // Callbacks
    var onDeactivate: (() -> Void)?

    // MARK: - Initialization

    init(
        window: Element,
        overlayWindow: OverlayWindow,
        sensitivity: Int = 20,
        reverseHorizontal: Bool = false,
        reverseVertical: Bool = false
    ) {
        self.window = window
        self.overlayWindow = overlayWindow
        self.sensitivity = sensitivity
        self.reverseHorizontal = reverseHorizontal
        self.reverseVertical = reverseVertical
    }

    // MARK: - Activation

    /// Activate scroll mode
    func activate() {
        print("📜 Activating scroll mode...")

        // Show border around window
        showBorder()

        // Start listening for keys
        startListening()
    }

    /// Deactivate scroll mode
    func deactivate() {
        print("👋 Deactivating scroll mode...")

        // Stop scrolling
        scroller?.stop()
        scroller = nil

        // Stop listening
        eventTap?.disable()
        eventTap = nil

        // Hide border
        hideBorder()

        // Hide overlay
        overlayWindow.orderOut(nil)

        // Notify
        onDeactivate?()
    }

    // MARK: - Border

    private func showBorder() {
        // Convert window frame to screen coordinates
        let globalFrame = GeometryUtils.convertAXFrameToGlobal(window.frame)

        // Determine which screen contains the window
        let activeScreen = findActiveScreen(for: globalFrame)

        // Create border view (Tokyo Night red)
        let border = NSView(frame: globalFrame)
        border.wantsLayer = true
        border.layer?.borderWidth = 3
        border.layer?.borderColor = TokyoNightTheme.scrollIndicator.cgColor
        border.layer?.backgroundColor = NSColor.clear.cgColor

        // Create container
        let container = NSView(frame: activeScreen.frame)
        container.addSubview(border)

        // Show overlay
        overlayWindow.contentView = container
        overlayWindow.setFrame(activeScreen.frame, display: true)
        overlayWindow.orderFrontRegardless()

        borderView = border
    }

    private func hideBorder() {
        borderView?.removeFromSuperview()
        borderView = nil
    }

    private func findActiveScreen(for windowFrame: NSRect) -> NSScreen {
        // Find screen with largest intersection
        var activeScreen = NSScreen.main ?? NSScreen.screens[0]
        var maxArea: CGFloat = 0

        for screen in NSScreen.screens {
            let intersection = screen.frame.intersection(windowFrame)
            let area = intersection.width * intersection.height
            if area > maxArea {
                maxArea = area
                activeScreen = screen
            }
        }

        return activeScreen
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

        // Only handle key down and key up
        guard event.type == .keyDown || event.type == .keyUp else {
            return event
        }

        // Escape - deactivate
        if nsEvent.keyCode == 53 { // Escape
            deactivate()
            return nil
        }

        guard let char = nsEvent.charactersIgnoringModifiers?.lowercased() else {
            return event
        }

        // Handle scroll keys
        if event.type == .keyDown {
            return handleScrollKeyDown(char)
        } else {
            return handleScrollKeyUp(char)
        }
    }

    private func handleScrollKeyDown(_ char: String) -> CGEvent? {
        let direction: ScrollDirection?

        switch char {
        case leftKey:
            direction = .left
        case downKey:
            direction = .down
        case upKey:
            direction = .up
        case rightKey:
            direction = .right
        case "g": // gg to go to top
            direction = .top
        case "G": // G to go to bottom
            direction = .bottom
        default:
            return nil // Pass through
        }

        guard let scrollDirection = direction else { return nil }

        // Stop current scroll
        scroller?.stop()

        // Start new scroll
        scroller = Scroller(
            direction: scrollDirection,
            sensitivity: sensitivity,
            reverseHorizontal: reverseHorizontal,
            reverseVertical: reverseVertical
        )
        scroller?.start()

        return nil // Consume event
    }

    private func handleScrollKeyUp(_ char: String) -> CGEvent? {
        // Stop scrolling when key is released
        if [leftKey, downKey, upKey, rightKey].contains(char) {
            scroller?.stop()
            scroller = nil
            return nil
        }

        return nil
    }
}
