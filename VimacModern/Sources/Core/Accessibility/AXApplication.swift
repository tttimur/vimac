//
//  AXApplication.swift
//  VimacModern
//
//  Application-level accessibility wrapper
//

import Cocoa
import ApplicationServices

/// Wrapper for application-level accessibility operations
class AXApplication {
    let app: NSRunningApplication
    let element: AXElement

    init?(_ app: NSRunningApplication) {
        self.app = app
        guard let element = AXElement.application(from: app) else {
            return nil
        }
        self.element = element
    }

    /// Get the focused window of the application
    func focusedWindow() throws -> AXElement? {
        return try element.attributeElement(.focusedWindow)
    }

    /// Get all windows of the application
    func windows() throws -> [AXElement]? {
        return try element.attributeElements(.windows)
    }

    /// Get the main window of the application
    func mainWindow() throws -> AXElement? {
        return try element.attributeElement(.mainWindow)
    }

    /// Get menu bar
    func menuBar() throws -> AXElement? {
        return try element.children()?.first { el in
            (try? el.role()) == AXRole.menuBar.rawValue
        }
    }
}

// MARK: - Notification Observation

extension AXApplication {
    typealias NotificationCallback = (String) -> Void

    /// Observe accessibility notifications
    func observeNotifications(_ notifications: [AXNotificationType], callback: @escaping NotificationCallback) -> AXNotificationObserver? {
        return AXNotificationObserver(application: self, notifications: notifications, callback: callback)
    }
}

/// Observer for accessibility notifications
class AXNotificationObserver {
    private let observer: AXObserver
    private let callback: AXApplication.NotificationCallback
    private var isObserving = false

    init?(application: AXApplication, notifications: [AXNotificationType], callback: @escaping AXApplication.NotificationCallback) {
        self.callback = callback

        var observerRef: AXObserver?
        let error = AXObserverCreate(application.app.processIdentifier, { (_, element, notification, refcon) in
            guard let refcon = refcon else { return }
            let observer = Unmanaged<AXNotificationObserver>.fromOpaque(refcon).takeUnretainedValue()
            observer.callback(notification as String)
        }, &observerRef)

        guard error == .success, let observer = observerRef else {
            return nil
        }

        self.observer = observer

        // Register notifications
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        for notification in notifications {
            AXObserverAddNotification(
                observer,
                application.element.element,
                notification.rawValue as CFString,
                selfPtr
            )
        }

        // Add to run loop
        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            AXObserverGetRunLoopSource(observer),
            .defaultMode
        )

        isObserving = true
    }

    deinit {
        stopObserving()
    }

    func stopObserving() {
        guard isObserving else { return }

        CFRunLoopRemoveSource(
            CFRunLoopGetCurrent(),
            AXObserverGetRunLoopSource(observer),
            .defaultMode
        )

        isObserving = false
    }
}
