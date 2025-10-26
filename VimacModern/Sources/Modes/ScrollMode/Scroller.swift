//
//  Scroller.swift
//  VimacModern
//
//  Smooth scrolling using CGEvents
//  Pure CoreGraphics, no dependencies
//

import Cocoa

/// Smooth scroller using timer-based scroll events
class Scroller {
    let direction: ScrollDirection
    let sensitivity: Int
    let reverseHorizontal: Bool
    let reverseVertical: Bool

    private let frequency: TimeInterval
    private let xAxis: Int32
    private let yAxis: Int32
    private var timer: Timer?

    init(
        direction: ScrollDirection,
        sensitivity: Int = 20,
        reverseHorizontal: Bool = false,
        reverseVertical: Bool = false
    ) {
        self.direction = direction
        self.sensitivity = sensitivity
        self.reverseHorizontal = reverseHorizontal
        self.reverseVertical = reverseVertical

        // Calculate scroll values
        var xAxis: Int32 = 0
        var yAxis: Int32 = 0
        var frequency: TimeInterval = 1.0 / 50.0 // 50 Hz for smooth scrolling

        switch direction {
        case .left:
            xAxis = Int32(sensitivity)
        case .right:
            xAxis = Int32(-sensitivity)
        case .up:
            yAxis = Int32(sensitivity)
        case .down:
            yAxis = Int32(-sensitivity)
        case .top:
            yAxis = Int32(Int16.max) // Scroll to top
            frequency = 0.25
        case .bottom:
            yAxis = Int32(Int16.min) // Scroll to bottom
            frequency = 0.25
        }

        // Apply reversal settings
        if reverseHorizontal {
            xAxis = -xAxis
        }

        if reverseVertical {
            yAxis = -yAxis
        }

        self.xAxis = xAxis
        self.yAxis = yAxis
        self.frequency = frequency
    }

    /// Start scrolling
    func start() {
        guard timer == nil else {
            print("⚠️ Scroller already started")
            return
        }

        // Emit first scroll immediately
        emitScrollEvent()

        // Start timer for continuous scrolling
        timer = Timer.scheduledTimer(
            withTimeInterval: frequency,
            repeats: true
        ) { [weak self] _ in
            self?.emitScrollEvent()
        }
    }

    /// Stop scrolling
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func emitScrollEvent() {
        guard let event = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .pixel,
            wheelCount: 2,
            wheel1: yAxis,
            wheel2: xAxis,
            wheel3: 0
        ) else {
            print("⚠️ Failed to create scroll event")
            return
        }

        event.post(tap: .cghidEventTap)
    }

    deinit {
        stop()
    }
}
