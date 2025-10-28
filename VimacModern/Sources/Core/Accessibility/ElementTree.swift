//
//  ElementTree.swift
//  VimacModern
//
//  Tree structure for organizing and querying hintable elements
//  Pure Swift, no dependencies
//

import Cocoa

/// Tree structure for managing accessibility elements and determining which should receive hints
class ElementTree {
    private var elementsById: [AXUIElement: Element] = [:]
    private var childrenById: [AXUIElement: [AXUIElement]] = [:]
    private var rootId: AXUIElement?

    // Cache for performance optimization
    private var cachedHintableChildrenCount: [AXUIElement: Int]?

    /// Insert an element into the tree
    /// - Parameters:
    ///   - element: The element to insert
    ///   - parentId: The parent element's ID (nil for root)
    /// - Returns: true if insertion succeeded, false if element already exists
    func insert(_ element: Element, parentId: AXUIElement?) -> Bool {
        let isRoot = parentId == nil

        // Check if element already exists
        if find(element.rawElement) != nil { return false }

        // Check if parent exists (if not root)
        if let parentId = parentId {
            if find(parentId) == nil { return false }
        }

        // Only allow one root
        if isRoot {
            if rootId != nil { return false }
            rootId = element.rawElement
        }

        // Insert element
        elementsById[element.rawElement] = element

        // Add to parent's children
        if let parentId = parentId {
            addChild(parentId, childId: element.rawElement)
        }

        return true
    }

    private func addChild(_ id: AXUIElement, childId: AXUIElement) {
        guard find(id) != nil, find(childId) != nil else { return }

        if childrenById[id] == nil {
            childrenById[id] = []
        }

        childrenById[id]?.append(childId)
    }

    /// Find an element by its AXUIElement ID
    func find(_ id: AXUIElement) -> Element? {
        return elementsById[id]
    }

    /// Query all hintable elements in the tree
    /// - Returns: Array of elements that should receive hints
    func query() -> [Element]? {
        guard let rootId = rootId else { return nil }

        // Initialize cache for this query
        cachedHintableChildrenCount = [:]

        var results: [Element] = []
        var stack: [Element] = [elementsById[rootId]!]

        // Depth-first traversal
        while let element = stack.popLast() {
            if isHintable(element) {
                results.append(element)
            }

            // Add children to stack
            if let children = children(element.rawElement) {
                stack.append(contentsOf: children)
            }
        }

        return results
    }

    /// Get children of an element
    func children(_ id: AXUIElement) -> [Element]? {
        guard let childIds = childrenById[id] else { return nil }
        return childIds.compactMap { elementsById[$0] }
    }

    // MARK: - Hintability Logic

    /// Determine if an element should receive a hint
    private func isHintable(_ element: Element) -> Bool {
        // Never hint windows or scroll areas
        if element.role == "AXWindow" || element.role == "AXScrollArea" {
            return false
        }

        // Element is hintable if it's actionable OR a row without hintable children
        return isActionable(element) || isRowWithoutHintableChildren(element)
    }

    /// Check if element has actionable actions
    private func isActionable(_ element: Element) -> Bool {
        // Ignore certain actions that aren't useful for hinting
        let ignoredActions: Set<String> = [
            "AXShowMenu",
            "AXScrollToVisible",
            "AXShowDefaultUI",
            "AXShowAlternateUI"
        ]

        let actions = Set(element.actions).subtracting(ignoredActions)
        return !actions.isEmpty
    }

    /// Check if element is a row without hintable children
    private func isRowWithoutHintableChildren(_ element: Element) -> Bool {
        return element.role == "AXRow" && hintableChildrenCount(element) == 0
    }

    /// Count hintable children recursively (with caching)
    private func hintableChildrenCount(_ element: Element) -> Int {
        guard cachedHintableChildrenCount != nil else {
            fatalError("hintableChildrenCount called before cache initialized")
        }

        // Return cached value if available
        if let cached = cachedHintableChildrenCount?[element.rawElement] {
            return cached
        }

        // Calculate count recursively
        let children = self.children(element.rawElement) ?? []
        let count = children
            .map { hintableChildrenCount($0) + (isHintable($0) ? 1 : 0) }
            .reduce(0, +)

        // Cache the result
        cachedHintableChildrenCount?[element.rawElement] = count
        return count
    }
}
