//
//  KeySequenceListener.swift
//  VimacModern
//
//  Listens for key sequences and publishes matches
//  Replaces RxSwift with Combine
//

import Cocoa
import Combine

/// Listens for key sequences (e.g., "fd", "jk") and publishes when matched
class KeySequenceListener {
    private let eventMask = CGEventMask.keyDown | .keyUp
    private var eventTap: EventTap?
    private let inputState: InputState
    private var keyUps: [CGEvent] = []
    private var typed: [CGEvent] = []
    private var sequences: [[Character]] = []
    private var timer: Timer?
    private let resetDelay: TimeInterval

    // Combine publisher for matched sequences
    private let matchSubject = PassthroughSubject<[Character], Never>()
    var matchPublisher: AnyPublisher<[Character], Never> {
        matchSubject.eraseToAnyPublisher()
    }

    init?(sequences: [[Character]], resetDelay: TimeInterval = 0.25) {
        self.resetDelay = resetDelay
        self.inputState = InputState()
        self.sequences = []

        var registeredCount = 0
        for seq in sequences {
            if let success = try? registerSequence(seq: seq), success {
                registeredCount += 1
            }
        }

        guard registeredCount > 0 else {
            return nil
        }
    }

    private func registerSequence(seq: [Character]) throws -> Bool {
        let success = try inputState.addWord(seq)
        if success {
            sequences.append(seq)
        }
        return success
    }

    /// Check if listener is currently active
    func isStarted() -> Bool {
        return eventTap?.isEnabled() ?? false
    }

    /// Start listening for key sequences
    func start() {
        if eventTap == nil {
            eventTap = EventTap(eventMask: eventMask) { [weak self] event in
                return self?.onEvent(event: event)
            }
        }

        eventTap?.enable()
    }

    /// Stop listening
    func stop() {
        eventTap?.disable()
        eventTap = nil
        resetInput()
    }

    private func onEvent(event: CGEvent) -> CGEvent? {
        guard let nsEvent = NSEvent(cgEvent: event) else {
            resetInput()
            return event
        }

        // Ignore events with modifiers (except deviceIndependentFlagsMask)
        let modifiersPresent = nsEvent.modifierFlags.rawValue != 256
        if modifiersPresent {
            resetInput()
            return event
        }

        guard let c = nsEvent.characters?.first else {
            resetInput()
            return event
        }

        // Ignore key repeats
        if nsEvent.isARepeat {
            resetInput()
            return event
        }

        // Track key ups separately
        if event.type == .keyUp {
            keyUps.append(event)
            return event
        }

        // Process key down
        typed.append(event)
        try? inputState.advance(c)

        switch inputState.state {
        case .advancable:
            setTimeout()
            return nil // Consume event

        case .matched:
            onMatch()
            resetInput()
            return nil // Consume event

        case .deadend:
            // If only one key typed, pass it through
            if typed.count == 1 {
                let e = typed.first!
                resetInput()
                return e
            }
            // Otherwise emit all typed events
            emitTyped()
            resetInput()
            return nil

        default:
            fatalError("Unexpected state: \(inputState.state)")
        }
    }

    private func onMatch() {
        if let sequence = try? inputState.matchedWord() {
            matchSubject.send(sequence)
        }
    }

    /// Emit all typed events (when sequence doesn't match)
    private func emitTyped() {
        for keyDownEvent in typed {
            guard let nsEvent = NSEvent(cgEvent: keyDownEvent) else { continue }

            keyDownEvent.post(tap: .cghidEventTap)

            // Find and post associated key up event
            if let associatedKeyUp = keyUps.first(where: { keyUp in
                guard let keyUpEvent = NSEvent(cgEvent: keyUp) else { return false }
                return keyUpEvent.charactersIgnoringModifiers == nsEvent.charactersIgnoringModifiers
            }) {
                associatedKeyUp.post(tap: .cghidEventTap)
            }
        }
    }

    private func resetInput() {
        typed = []
        keyUps = []
        inputState.resetInput()
        timer?.invalidate()
        timer = nil
    }

    @objc private func onTimeout() {
        emitTyped()
        resetInput()
    }

    private func setTimeout() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: resetDelay,
            target: self,
            selector: #selector(onTimeout),
            userInfo: nil,
            repeats: false
        )
    }
}
