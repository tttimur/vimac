//
//  GeometryUtils.swift
//  VimacModern
//
//  Coordinate transformations and geometry utilities
//  Pure Cocoa, no dependencies
//

import Cocoa

enum GeometryUtils {
    /// Calculate the center point of a frame
    static func center(_ frame: NSRect) -> NSPoint {
        NSPoint(
            x: frame.origin.x + (frame.size.width / 2),
            y: frame.origin.y + (frame.size.height / 2)
        )
    }

    /// Calculate a corner point with optional offset
    static func corner(_ frame: NSRect, top: Bool, right: Bool, offset: CGFloat) -> NSPoint {
        var x = CGFloat(0)
        var y = CGFloat(0)

        var xOffset = CGFloat(0)
        var yOffset = CGFloat(0)

        if offset < frame.width {
            xOffset = offset
        } else {
            xOffset = CGFloat(0)
        }

        if offset < frame.height {
            yOffset = offset
        } else {
            yOffset = CGFloat(0)
        }

        if right {
            x = frame.maxX - xOffset
        } else {
            x = frame.origin.x + xOffset
        }

        if top {
            y = frame.maxY - yOffset
        } else {
            y = frame.origin.y + yOffset
        }

        return NSPoint(x: x, y: y)
    }

    /// Convert global frame to coordinates relative to a point
    static func convertGlobalFrame(_ globalFrame: NSRect, relativeTo: NSPoint) -> NSRect {
        let menuBarScreen = NSScreen.screens.first!

        let origin = changeOrigin(globalFrame.origin, fromOrigin: menuBarScreen.frame.origin, toOrigin: relativeTo)
        return NSRect(origin: origin, size: globalFrame.size)
    }

    /// Convert Accessibility frame (top-left origin) to global screen coordinates (bottom-left origin)
    static func convertAXFrameToGlobal(_ axFrame: NSRect) -> NSRect {
        let menuBarScreen = NSScreen.screens.first!

        // Uninvert the y-axis
        let topLeftRelativeToTopLeftMenuBar: NSPoint = NSPoint(
            x: axFrame.origin.x,
            y: -axFrame.origin.y
        )

        let topLeftMenuBarPosition = NSPoint(
            x: menuBarScreen.frame.origin.x,
            y: menuBarScreen.frame.origin.y + menuBarScreen.frame.height
        )

        let topLeftRelativeToGlobalOrigin = changeOrigin(
            topLeftRelativeToTopLeftMenuBar,
            fromOrigin: topLeftMenuBarPosition,
            toOrigin: menuBarScreen.frame.origin
        )

        let bottomLeftRelativeToGlobalOrigin = NSPoint(
            x: topLeftRelativeToGlobalOrigin.x,
            y: topLeftRelativeToGlobalOrigin.y - axFrame.height
        )

        return NSRect(origin: bottomLeftRelativeToGlobalOrigin, size: axFrame.size)
    }

    /// Change origin of a point from one coordinate system to another
    static func changeOrigin(_ point: NSPoint, fromOrigin: NSPoint, toOrigin: NSPoint) -> NSPoint {
        let deltaX = toOrigin.x - fromOrigin.x
        let deltaY = toOrigin.y - fromOrigin.y
        let x = point.x - deltaX
        let y = point.y - deltaY
        return NSPoint(x: x, y: y)
    }
}
