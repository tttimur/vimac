//
//  AXElement.swift
//  VimacModern
//
//  Native wrapper around AXUIElement (replaces AXSwift.UIElement)
//  Zero dependencies, pure Accessibility.framework
//

import Cocoa
import ApplicationServices

/// Errors that can occur during accessibility operations
enum AXError: Error {
    case apiDisabled
    case invalidUIElement
    case cannotComplete
    case attributeUnsupported
    case actionUnsupported
    case notificationUnsupported
    case notImplemented
    case notEnoughPrecision
    case noValue
    case failure
    case illegalArgument
    case notificationAlreadyRegistered
    case notificationNotRegistered
    case timeout

    init(code: AXError.Code) {
        switch code {
        case .apiDisabled: self = .apiDisabled
        case .invalidUIElement: self = .invalidUIElement
        case .cannotComplete: self = .cannotComplete
        case .attributeUnsupported: self = .attributeUnsupported
        case .actionUnsupported: self = .actionUnsupported
        case .notificationUnsupported: self = .notificationUnsupported
        case .notImplemented: self = .notImplemented
        case .notEnoughPrecision: self = .notEnoughPrecision
        case .noValue: self = .noValue
        case .failure: self = .failure
        case .illegalArgument: self = .illegalArgument
        case .notificationAlreadyRegistered: self = .notificationAlreadyRegistered
        case .notificationNotRegistered: self = .notificationNotRegistered
        @unknown default: self = .failure
        }
    }
}

/// Swift wrapper around AXUIElement
class AXElement {
    let element: AXUIElement

    init(_ element: AXUIElement) {
        self.element = element
    }

    /// Create an AXElement for a running application
    static func application(from app: NSRunningApplication) -> AXElement? {
        guard let pid = app.processIdentifier as pid_t? else { return nil }
        let element = AXUIElementCreateApplication(pid)
        return AXElement(element)
    }

    /// Create a system-wide AXElement
    static func systemWide() -> AXElement {
        return AXElement(AXUIElementCreateSystemWide())
    }

    // MARK: - Attribute Access

    /// Get a single attribute value
    func attribute<T>(_ attribute: AXAttribute) throws -> T? {
        var value: AnyObject?
        let error = AXUIElementCopyAttributeValue(element, attribute.rawValue as CFString, &value)

        guard error == .success else {
            if error == .noValue {
                return nil
            }
            throw AXError(code: error)
        }

        return value as? T
    }

    /// Get multiple attributes at once (more efficient than calling attribute() multiple times)
    func attributes(_ attributes: [AXAttribute]) throws -> [AXAttribute: Any] {
        var result: [AXAttribute: Any] = [:]

        for attr in attributes {
            if let value: Any = try? attribute(attr) {
                result[attr] = value
            }
        }

        return result
    }

    /// Get an attribute as an AXElement
    func attributeElement(_ attribute: AXAttribute) throws -> AXElement? {
        guard let rawElement: AXUIElement = try attribute(attribute) else {
            return nil
        }
        return AXElement(rawElement)
    }

    /// Get an attribute as an array of AXElements
    func attributeElements(_ attribute: AXAttribute) throws -> [AXElement]? {
        guard let rawElements: [AXUIElement] = try attribute(attribute) else {
            return nil
        }
        return rawElements.map { AXElement($0) }
    }

    /// Set an attribute value
    func setAttribute(_ attribute: AXAttribute, value: Any) throws {
        let error = AXUIElementSetAttributeValue(element, attribute.rawValue as CFString, value as CFTypeRef)
        guard error == .success else {
            throw AXError(code: error)
        }
    }

    // MARK: - Role & Properties

    /// Get the role of this element
    func role() throws -> String? {
        return try attribute(.role)
    }

    /// Get the subrole of this element
    func subrole() throws -> String? {
        return try attribute(.subrole)
    }

    /// Get the title of this element
    func title() throws -> String? {
        return try attribute(.title)
    }

    /// Get the position of this element
    func position() throws -> CGPoint? {
        guard let value: AXValue = try attribute(.position) else { return nil }
        var point = CGPoint.zero
        guard AXValueGetValue(value, .cgPoint, &point) else { return nil }
        return point
    }

    /// Get the size of this element
    func size() throws -> CGSize? {
        guard let value: AXValue = try attribute(.size) else { return nil }
        var size = CGSize.zero
        guard AXValueGetValue(value, .cgSize, &size) else { return nil }
        return size
    }

    /// Get the frame (position + size) of this element
    func frame() throws -> CGRect? {
        guard let position = try position(),
              let size = try size() else {
            return nil
        }
        return CGRect(origin: position, size: size)
    }

    /// Get children elements
    func children() throws -> [AXElement]? {
        return try attributeElements(.children)
    }

    /// Get parent element
    func parent() throws -> AXElement? {
        return try attributeElement(.parent)
    }

    // MARK: - Actions

    /// Get available action names
    func actionNames() throws -> [String] {
        var actionNames: CFArray?
        let error = AXUIElementCopyActionNames(element, &actionNames)

        guard error == .success, let names = actionNames as? [String] else {
            return []
        }

        return names
    }

    /// Perform an action
    func performAction(_ action: String) throws {
        let error = AXUIElementPerformAction(element, action as CFString)
        guard error == .success else {
            throw AXError(code: error)
        }
    }

    /// Perform an action by enum
    func performAction(_ action: AXAction) throws {
        try performAction(action.rawValue)
    }

    // MARK: - Convenience Methods

    /// Check if element has a specific action
    func hasAction(_ action: String) -> Bool {
        return (try? actionNames().contains(action)) ?? false
    }

    /// Check if element is enabled
    func isEnabled() -> Bool {
        return (try? attribute(.enabled)) ?? false
    }

    /// Get the process ID of the element's application
    func pid() throws -> pid_t {
        var pid: pid_t = 0
        let error = AXUIElementGetPid(element, &pid)
        guard error == .success else {
            throw AXError(code: error)
        }
        return pid
    }
}

// MARK: - Hashable & Equatable

extension AXElement: Hashable {
    static func == (lhs: AXElement, rhs: AXElement) -> Bool {
        return CFEqual(lhs.element, rhs.element)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(CFHash(element))
    }
}

// MARK: - CustomStringConvertible

extension AXElement: CustomStringConvertible {
    var description: String {
        let roleStr = (try? role()) ?? "Unknown"
        let titleStr = (try? title()) ?? ""
        return "AXElement(role: \(roleStr), title: \"\(titleStr)\")"
    }
}
