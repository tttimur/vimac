//
//  AXAttribute.swift
//  VimacModern
//
//  Native replacement for AXSwift attributes
//

import Foundation
import ApplicationServices

/// Common accessibility attributes (replaces AXSwift.Attribute)
enum AXAttribute: String {
    case role = "AXRole"
    case subrole = "AXSubrole"
    case title = "AXTitle"
    case value = "AXValue"
    case children = "AXChildren"
    case parent = "AXParent"
    case position = "AXPosition"
    case size = "AXSize"
    case description = "AXDescription"
    case focused = "AXFocused"
    case focusedWindow = "AXFocusedWindow"
    case mainWindow = "AXMainWindow"
    case windows = "AXWindows"
    case enabled = "AXEnabled"
    case selected = "AXSelected"
    case identifier = "AXIdentifier"
    case frame = "AXFrame"

    var rawValue: String {
        switch self {
        case .role: return kAXRoleAttribute as String
        case .subrole: return kAXSubroleAttribute as String
        case .title: return kAXTitleAttribute as String
        case .value: return kAXValueAttribute as String
        case .children: return kAXChildrenAttribute as String
        case .parent: return kAXParentAttribute as String
        case .position: return kAXPositionAttribute as String
        case .size: return kAXSizeAttribute as String
        case .description: return kAXDescriptionAttribute as String
        case .focused: return kAXFocusedAttribute as String
        case .focusedWindow: return kAXFocusedWindowAttribute as String
        case .mainWindow: return kAXMainWindowAttribute as String
        case .windows: return kAXWindowsAttribute as String
        case .enabled: return kAXEnabledAttribute as String
        case .selected: return kAXSelectedAttribute as String
        case .identifier: return kAXIdentifierAttribute as String
        case .frame: return "AXFrame"
        }
    }
}

/// Common accessibility roles
enum AXRole: String {
    case button = "AXButton"
    case window = "AXWindow"
    case application = "AXApplication"
    case staticText = "AXStaticText"
    case textField = "AXTextField"
    case group = "AXGroup"
    case scrollArea = "AXScrollArea"
    case link = "AXLink"
    case image = "AXImage"
    case menuBar = "AXMenuBar"
    case menuBarItem = "AXMenuBarItem"
    case menu = "AXMenu"
    case menuItem = "AXMenuItem"
    case table = "AXTable"
    case row = "AXRow"
    case cell = "AXCell"
    case list = "AXList"
    case unknown = "AXUnknown"
}

/// Common accessibility actions
enum AXAction: String {
    case press = "AXPress"
    case pick = "AXPick"
    case cancel = "AXCancel"
    case confirm = "AXConfirm"
    case decrement = "AXDecrement"
    case increment = "AXIncrement"
    case showMenu = "AXShowMenu"
    case raise = "AXRaise"
}

/// Common accessibility notifications
enum AXNotificationType: String {
    case focusedWindowChanged = "AXFocusedWindowChanged"
    case windowMoved = "AXWindowMoved"
    case windowResized = "AXWindowResized"
    case windowMiniaturized = "AXWindowMiniaturized"
    case windowDeminiaturized = "AXWindowDeminiaturized"
    case applicationActivated = "AXApplicationActivated"
    case applicationDeactivated = "AXApplicationDeactivated"
    case focusedUIElementChanged = "AXFocusedUIElementChanged"
    case valueChanged = "AXValueChanged"
    case titleChanged = "AXTitleChanged"
    case selectedChildrenChanged = "AXSelectedChildrenChanged"

    var rawValue: String {
        switch self {
        case .focusedWindowChanged: return kAXFocusedWindowChangedNotification as String
        case .windowMoved: return kAXWindowMovedNotification as String
        case .windowResized: return kAXWindowResizedNotification as String
        case .windowMiniaturized: return kAXWindowMiniaturizedNotification as String
        case .windowDeminiaturized: return kAXWindowDeminiaturizedNotification as String
        case .applicationActivated: return kAXApplicationActivatedNotification as String
        case .applicationDeactivated: return kAXApplicationDeactivatedNotification as String
        case .focusedUIElementChanged: return kAXFocusedUIElementChangedNotification as String
        case .valueChanged: return kAXValueChangedNotification as String
        case .titleChanged: return kAXTitleChangedNotification as String
        case .selectedChildrenChanged: return kAXSelectedChildrenChangedNotification as String
        }
    }
}
