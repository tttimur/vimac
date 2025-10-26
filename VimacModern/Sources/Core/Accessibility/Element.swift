//
//  Element.swift
//  VimacModern
//
//  High-level element wrapper with cached properties
//  Compatible with existing Vimac API
//

import Cocoa

/// High-level wrapper around AXElement with cached properties
class Element {
    let rawElement: AXUIElement
    let frame: NSRect
    let actions: [String]
    let role: String

    var clippedFrame: NSRect?

    /// Initialize from an AXUIElement by querying its properties
    static func initialize(rawElement: AXUIElement) -> Element? {
        let axElement = AXElement(rawElement)

        // Query multiple attributes
        guard let frame = try? axElement.frame(),
              let role = try? axElement.role() else {
            return nil
        }

        let actions = (try? axElement.actionNames()) ?? []

        return Element(
            rawElement: rawElement,
            frame: frame,
            actions: actions,
            role: role
        )
    }

    init(rawElement: AXUIElement, frame: NSRect, actions: [String], role: String) {
        self.rawElement = rawElement
        self.frame = frame
        self.actions = actions
        self.role = role
    }

    func setClippedFrame(_ clippedFrame: NSRect) {
        self.clippedFrame = clippedFrame
    }

    /// Perform an action on this element
    func performAction(_ action: String) throws {
        try AXElement(rawElement).performAction(action)
    }

    /// Get children of this element
    func children() throws -> [Element] {
        let axElement = AXElement(rawElement)
        guard let children = try axElement.children() else {
            return []
        }

        return children.compactMap { Element.initialize(rawElement: $0.element) }
    }
}

// MARK: - CustomStringConvertible

extension Element: CustomStringConvertible {
    var description: String {
        return "Element(role: \(role), frame: \(frame), actions: \(actions.count))"
    }
}

// MARK: - Hashable & Equatable

extension Element: Hashable {
    static func == (lhs: Element, rhs: Element) -> Bool {
        return CFEqual(lhs.rawElement, rhs.rawElement)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(CFHash(rawElement))
    }
}
