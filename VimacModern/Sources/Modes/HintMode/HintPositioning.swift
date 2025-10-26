//
//  HintPositioning.swift
//  VimacModern
//
//  Logic for positioning hints on elements
//  Pure Swift, no dependencies
//

import Cocoa

/// Hint positioning strategies
enum HintPositioning {
    /// Position hint at center of element
    static func center(_ element: Element) -> CGPoint {
        return GeometryUtils.center(element.clippedFrame ?? element.frame)
    }

    /// Position hint at corner of element (for links)
    static func bottomLeft(_ element: Element, offset: CGFloat = 5) -> CGPoint {
        let frame = element.clippedFrame ?? element.frame
        return GeometryUtils.corner(frame, top: false, right: false, offset: offset)
    }

    /// Determine best position for element based on role
    static func bestPosition(for element: Element) -> CGPoint {
        // Links get bottom-left positioning
        if element.role == "AXLink" {
            return bottomLeft(element)
        }

        // Everything else gets centered
        return center(element)
    }

    /// Convert AX frame to screen coordinates and clip to visible area
    static func convertToScreenCoordinates(_ frame: NSRect) -> NSRect {
        return GeometryUtils.convertAXFrameToGlobal(frame)
    }

    /// Check if hint position is visible on any screen
    static func isVisible(_ position: CGPoint) -> Bool {
        for screen in NSScreen.screens {
            if screen.frame.contains(position) {
                return true
            }
        }
        return false
    }

    /// Generate hints with proper positioning
    static func generateHints(
        for elements: [Element],
        hintCharacters: String = "sadfjklewcmpgh"
    ) -> [Hint] {
        // Generate hint strings
        let hintStrings = AlphabetHints.generate(count: elements.count, using: hintCharacters)

        // Zip elements with hint strings and calculate positions
        return zip(elements, hintStrings).map { element, text in
            let position = bestPosition(for: element)
            return Hint(element: element, text: text, position: position)
        }
    }
}
