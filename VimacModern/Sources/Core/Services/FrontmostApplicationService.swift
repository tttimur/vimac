//
//  FrontmostApplicationService.swift
//  VimacModern
//
//  Observes frontmost application and focused window
//  Replaces RxSwift with Combine
//

import Cocoa
import Combine

/// Service for observing the frontmost application and its focused window
class FrontmostApplicationService {
    // MARK: - Publishers

    /// Publishes the currently frontmost application
    let frontmostAppPublisher: AnyPublisher<NSRunningApplication?, Never>

    /// Publishes the focused window of the frontmost application
    let focusedWindowPublisher: AnyPublisher<Element?, Never>

    // MARK: - Private

    private let frontmostAppSubject = CurrentValueSubject<NSRunningApplication?, Never>(nil)
    private let focusedWindowSubject = CurrentValueSubject<Element?, Never>(nil)
    private var cancellables = Set<AnyCancellable>()
    private var observers: [AXNotificationObserver] = []

    init() {
        // Create publishers
        self.frontmostAppPublisher = frontmostAppSubject
            .removeDuplicates { $0?.processIdentifier == $1?.processIdentifier }
            .eraseToAnyPublisher()

        self.focusedWindowPublisher = focusedWindowSubject
            .removeDuplicates()
            .eraseToAnyPublisher()

        // Start observing
        startObserving()
    }

    private func startObserving() {
        // Observe frontmost application changes
        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .compactMap { notification in
                notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            }
            .sink { [weak self] app in
                self?.onFrontmostAppChanged(app)
            }
            .store(in: &cancellables)

        // Set initial frontmost app
        if let app = NSWorkspace.shared.frontmostApplication {
            onFrontmostAppChanged(app)
        }
    }

    private func onFrontmostAppChanged(_ app: NSRunningApplication) {
        frontmostAppSubject.send(app)

        // Clean up old observers
        observers.removeAll()

        // Create accessibility application
        guard let axApp = AXApplication(app) else {
            focusedWindowSubject.send(nil)
            return
        }

        // Get initial focused window
        updateFocusedWindow(for: axApp)

        // Observe window changes
        if let observer = axApp.observeNotifications([
            .focusedWindowChanged,
            .windowMoved,
            .windowMiniaturized
        ], callback: { [weak self] _ in
            self?.updateFocusedWindow(for: axApp)
        }) {
            observers.append(observer)
        }
    }

    private func updateFocusedWindow(for axApp: AXApplication) {
        if let focusedWindow = try? axApp.focusedWindow(),
           let element = Element.initialize(rawElement: focusedWindow.element) {
            focusedWindowSubject.send(element)
        } else {
            focusedWindowSubject.send(nil)
        }
    }
}
