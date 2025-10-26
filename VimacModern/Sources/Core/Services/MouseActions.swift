//
//  MouseActions.swift
//  VimacModern
//
//  Mouse movement and click actions
//  Pure CoreGraphics, no dependencies
//

import Cocoa

enum MouseActions {
    /// Move mouse to position
    static func moveMouse(to position: CGPoint) {
        let moveEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: .mouseMoved,
            mouseCursorPosition: position,
            mouseButton: .left
        )
        moveEvent?.post(tap: .cghidEventTap)
    }

    /// Perform left click at position
    static func leftClick(at position: CGPoint) {
        let downEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDown,
            mouseCursorPosition: position,
            mouseButton: .left
        )

        let upEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseUp,
            mouseCursorPosition: position,
            mouseButton: .left
        )

        // Set click state for proper recognition
        downEvent?.setIntegerValueField(.mouseEventClickState, value: 1)
        upEvent?.setIntegerValueField(.mouseEventClickState, value: 1)

        // Clear flags to prevent modifier key interference
        // (e.g., CTRL + left click -> right click)
        downEvent?.flags = .init()
        upEvent?.flags = .init()

        downEvent?.post(tap: .cghidEventTap)
        upEvent?.post(tap: .cghidEventTap)
    }

    /// Perform double click at position
    static func doubleClick(at position: CGPoint) {
        let event = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDown,
            mouseCursorPosition: position,
            mouseButton: .left
        )

        event?.setIntegerValueField(.mouseEventClickState, value: 1)
        event?.flags = .init()

        // First click
        event?.post(tap: .cghidEventTap)
        event?.type = .leftMouseUp
        event?.post(tap: .cghidEventTap)

        // Second click
        event?.setIntegerValueField(.mouseEventClickState, value: 2)
        event?.type = .leftMouseDown
        event?.post(tap: .cghidEventTap)
        event?.type = .leftMouseUp
        event?.post(tap: .cghidEventTap)
    }

    /// Perform right click at position
    static func rightClick(at position: CGPoint) {
        let downEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: .rightMouseDown,
            mouseCursorPosition: position,
            mouseButton: .right
        )

        let upEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: .rightMouseUp,
            mouseCursorPosition: position,
            mouseButton: .right
        )

        downEvent?.setIntegerValueField(.mouseEventClickState, value: 1)
        downEvent?.flags = .init()
        upEvent?.setIntegerValueField(.mouseEventClickState, value: 1)
        upEvent?.flags = .init()

        downEvent?.post(tap: .cghidEventTap)
        upEvent?.post(tap: .cghidEventTap)
    }

    /// Hide cursor globally
    static func hideCursor() {
        CGDisplayHideCursor(CGMainDisplayID())
    }

    /// Show cursor globally
    static func showCursor() {
        CGDisplayShowCursor(CGMainDisplayID())
    }
}
