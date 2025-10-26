//
//  EventTap.swift
//  VimacModern
//
//  Global event tap for keyboard/mouse events
//  Pure CoreGraphics, no dependencies
//

import Cocoa
import Combine
import os.log

/// Wrapper around CGEventTap for monitoring global keyboard/mouse events
class EventTap {
    let eventMask: CGEventMask
    let eventHandler: (CGEvent) -> CGEvent?

    private var runLoopSource: CFRunLoopSource?
    private var eventTap: CFMachPort?
    private var selfPtr: Unmanaged<EventTap>!
    private let logger = Logger(subsystem: "com.vimac.modern", category: "EventTap")

    init(eventMask: CGEventMask, onEvent: @escaping (CGEvent) -> CGEvent?) {
        self.eventMask = eventMask
        self.eventHandler = onEvent
        selfPtr = Unmanaged.passRetained(self)
    }

    deinit {
        disable()
        selfPtr?.release()
    }

    /// Check if event tap is currently enabled
    func isEnabled() -> Bool {
        guard let tap = eventTap else { return false }
        return CGEvent.tapIsEnabled(tap: tap)
    }

    /// Enable the event tap
    @discardableResult
    func enable() -> Bool {
        // Clean up existing tap if it's disabled
        if let tap = eventTap {
            if CGEvent.tapIsEnabled(tap: tap) {
                return true
            } else {
                cleanupTap()
            }
        }

        guard let tap = createEventTap() else {
            logger.error("Failed to create event tap")
            return false
        }

        self.eventTap = tap
        self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        logger.info("Event tap enabled")
        return true
    }

    /// Disable the event tap
    func disable() {
        guard let tap = eventTap else { return }

        if CGEvent.tapIsEnabled(tap: tap) {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        cleanupTap()
        logger.info("Event tap disabled")
    }

    private func cleanupTap() {
        if let tap = eventTap {
            CFMachPortInvalidate(tap)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }

    private func eventTapCallback(
        proxy: CGEventTapProxy,
        type: CGEventType,
        event: CGEvent,
        refcon: UnsafeMutableRawPointer?
    ) -> Unmanaged<CGEvent>? {
        // Handle tap disabled events
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            logger.warning("Event tap disabled by \(type == .tapDisabledByTimeout ? "timeout" : "user input"), re-enabling")
            if let tap = eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
            return Unmanaged.passUnretained(event)
        }

        // Call user handler
        if let processedEvent = eventHandler(event) {
            return Unmanaged.passRetained(processedEvent).autorelease()
        }

        // nil means event is consumed (not passed through)
        return nil
    }

    private func createEventTap() -> CFMachPort? {
        return CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { proxy, type, event, refcon in
                let mySelf = Unmanaged<EventTap>.fromOpaque(refcon!).takeUnretainedValue()
                return mySelf.eventTapCallback(proxy: proxy, type: type, event: event, refcon: refcon)
            },
            userInfo: selfPtr.toOpaque()
        )
    }
}

// MARK: - Combine Support

extension EventTap {
    /// Create an event tap that publishes events via Combine
    static func publisher(
        for eventMask: CGEventMask,
        passthrough: Bool = false
    ) -> AnyPublisher<CGEvent, Never> {
        let subject = PassthroughSubject<CGEvent, Never>()

        let tap = EventTap(eventMask: eventMask) { event in
            subject.send(event)
            return passthrough ? event : nil
        }

        tap.enable()

        return subject
            .handleEvents(receiveCancel: {
                tap.disable()
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Convenience Event Masks

extension CGEventMask {
    static let keyDown = CGEventMask(1 << CGEventType.keyDown.rawValue)
    static let keyUp = CGEventMask(1 << CGEventType.keyUp.rawValue)
    static let flagsChanged = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
    static let allKeyboard = keyDown | keyUp | flagsChanged

    static let leftMouseDown = CGEventMask(1 << CGEventType.leftMouseDown.rawValue)
    static let leftMouseUp = CGEventMask(1 << CGEventType.leftMouseUp.rawValue)
    static let rightMouseDown = CGEventMask(1 << CGEventType.rightMouseDown.rawValue)
    static let rightMouseUp = CGEventMask(1 << CGEventType.rightMouseUp.rawValue)
    static let mouseMoved = CGEventMask(1 << CGEventType.mouseMoved.rawValue)
    static let allMouse = leftMouseDown | leftMouseUp | rightMouseDown | rightMouseUp | mouseMoved
}
