//
//  TraverseElementService.swift
//  VimacModern
//
//  Traverses accessibility element hierarchies to build element tree
//  Pure Swift, no dependencies
//

import Cocoa

/// Service for traversing accessibility element hierarchies
class TraverseElementService {
    let tree: ElementTree
    let element: Element
    let parent: Element?
    let app: NSRunningApplication
    let windowElement: Element
    let clipBounds: NSRect?

    init(
        tree: ElementTree,
        element: Element,
        parent: Element?,
        app: NSRunningApplication,
        windowElement: Element,
        clipBounds: NSRect?
    ) {
        self.tree = tree
        self.element = element
        self.parent = parent
        self.app = app
        self.windowElement = windowElement
        self.clipBounds = clipBounds
    }

    /// Perform the traversal
    func perform() {
        // Skip invisible elements
        guard isElementVisible() else { return }

        // Set clipped frame
        element.setClippedFrame(elementClippedBounds())

        // Insert into tree
        guard tree.insert(element, parentId: parent?.rawElement) else { return }

        // Traverse children
        if let children = getChildren(element) {
            for child in children {
                traverseChild(child)
            }
        }
    }

    // MARK: - Visibility

    private func isElementVisible() -> Bool {
        guard let clipBounds = clipBounds else { return true }
        return clipBounds.intersects(element.frame)
    }

    private func elementClippedBounds() -> NSRect {
        guard let clipBounds = clipBounds else { return element.frame }
        return clipBounds.intersection(element.frame)
    }

    // MARK: - Children

    private func getChildren(_ element: Element) -> [Element]? {
        let axElement = AXElement(element.rawElement)

        do {
            // Special case: Tables and Outlines use visible rows
            if element.role == "AXTable" || element.role == "AXOutline" {
                if let rows: [AXUIElement] = try axElement.attribute(AXAttribute(rawValue: "AXVisibleRows")) {
                    return rows.compactMap { Element.initialize(rawElement: $0) }
                }
            }

            // Special case: WebAreas with search predicate support
            if element.role == "AXWebArea" && supportsSearchPredicate(element) {
                return getWebAreaChildrenViaSearchPredicate(element)
            }

            // Default: Get children attribute
            if let children: [AXUIElement] = try axElement.attribute(.children) {
                return children.compactMap { Element.initialize(rawElement: $0) }
            }
        } catch {
            // Failed to get children
            return nil
        }

        return nil
    }

    private func supportsSearchPredicate(_ element: Element) -> Bool {
        // Check if element supports AXUIElementsForSearchPredicate
        var attrs: CFArray?
        let error = AXUIElementCopyParameterizedAttributeNames(element.rawElement, &attrs)
        guard error == .success, let attributes = attrs as? [String] else {
            return false
        }
        return attributes.contains("AXUIElementsForSearchPredicate")
    }

    private func getWebAreaChildrenViaSearchPredicate(_ element: Element) -> [Element]? {
        // Use search predicate for web areas (more efficient)
        let predicate: [String: Any] = [
            "AXSearchKey": "AXInteractiveElementSearchKey",
            "AXResultsLimit": -1, // No limit
            "AXDirection": "AXDirectionNext"
        ]

        var result: AnyObject?
        let error = AXUIElementCopyParameterizedAttributeValue(
            element.rawElement,
            "AXUIElementsForSearchPredicate" as CFString,
            predicate as CFDictionary,
            &result
        )

        guard error == .success, let elements = result as? [AXUIElement] else {
            return nil
        }

        return elements.compactMap { Element.initialize(rawElement: $0) }
    }

    // MARK: - Traversal

    private func traverseChild(_ child: Element) {
        let childService = TraverseElementService(
            tree: tree,
            element: child,
            parent: self.element,
            app: app,
            windowElement: windowElement,
            clipBounds: elementClippedBounds()
        )
        childService.perform()
    }
}
