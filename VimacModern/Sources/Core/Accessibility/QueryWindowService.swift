//
//  QueryWindowService.swift
//  VimacModern
//
//  Queries all hintable elements from a window
//  Pure Swift, no dependencies
//

import Cocoa

/// Service for querying all hintable elements in a window
class QueryWindowService {
    let app: NSRunningApplication
    let window: Element

    init(app: NSRunningApplication, window: Element) {
        self.app = app
        self.window = window
    }

    /// Query all hintable elements in the window
    /// - Returns: Array of elements that should receive hints
    func perform() -> [Element] {
        let tree = ElementTree()

        // Traverse the window's element hierarchy
        let service = TraverseElementService(
            tree: tree,
            element: window,
            parent: nil,
            app: app,
            windowElement: window,
            clipBounds: nil
        )
        service.perform()

        // Query hintable elements from the tree
        return tree.query() ?? []
    }
}
