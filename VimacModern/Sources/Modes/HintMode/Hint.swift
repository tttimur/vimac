//
//  Hint.swift
//  VimacModern
//
//  Model for a hint (element + hint text)
//

import Foundation

/// A hint associating an element with a hint string
struct Hint {
    let element: Element
    let text: String
    let position: CGPoint

    init(element: Element, text: String) {
        self.element = element
        self.text = text
        // Calculate position (center of element by default)
        self.position = CGPoint(
            x: element.frame.midX,
            y: element.frame.midY
        )
    }

    init(element: Element, text: String, position: CGPoint) {
        self.element = element
        self.text = text
        self.position = position
    }
}

extension Hint: Equatable {
    static func == (lhs: Hint, rhs: Hint) -> Bool {
        return lhs.element == rhs.element && lhs.text == rhs.text
    }
}

extension Hint: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(element)
        hasher.combine(text)
    }
}
