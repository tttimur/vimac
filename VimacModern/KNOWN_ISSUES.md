# ⚠️ Known Issues & Solutions

## Compilation Issues

### 1. Duplicate `@main` Attribute

**Error:**
```
Multiple @main found in module
```

**Cause**: Both `VimacApp.swift` (demo) and `VimacApp_Updated.swift` have `@main`

**Solution:**
```bash
# Option A: Rename (recommended)
cd Sources/App
mv VimacApp_Updated.swift VimacApp.swift  # Overwrite old one

# Option B: Delete old demo
rm VimacApp.swift  # Then rename Updated version
```

---

### 2. AppStorage Conflict

**Error:**
```
Ambiguous use of 'AppStorage'
Invalid redeclaration of 'AppStorage'
```

**Cause**: Custom `AppStorage` in `ModeCoordinator.swift` conflicts with SwiftUI's

**Solution:**

In `ModeCoordinator.swift`:

```swift
import SwiftUI  // Add this at top

// ... rest of code ...

// DELETE these lines at the bottom (custom AppStorage):
@propertyWrapper
struct AppStorage<Value> {
    // ... delete entire implementation ...
}
```

Or rename custom one:
```swift
@propertyWrapper
struct UserDefaultsStorage<Value> {  // Rename
    // ... keep implementation ...
}

// Then update usages:
@UserDefaultsStorage("hintCharacters") private var hintCharacters = "..."
```

---

### 3. Cannot Find 'AXAttribute' in Scope

**Error:**
```
Cannot find type 'AXAttribute' in scope
```

**Cause**: Missing import or file not in target

**Solution:**
1. Check file is added to target:
   - Select file in Xcode
   - Right sidebar → Target Membership
   - Check ✅ VimacModern

2. Add import if needed:
```swift
import Foundation
import ApplicationServices
```

---

### 4. Undefined Symbol: _main

**Error:**
```
Undefined symbol: _main
```

**Cause**: No `@main` entry point found

**Solution:**
Ensure `VimacApp.swift` has:
```swift
@main
class VimacApp: NSApplication, NSApplicationDelegate {
    // ...
}
```

---

### 5. Module 'SwiftUI' Not Found

**Error:**
```
No such module 'SwiftUI'
```

**Cause**: SwiftUI framework not linked

**Solution:**
1. Select **VimacModern** target
2. **General** tab → **Frameworks and Libraries**
3. Click **+** → Add `SwiftUI.framework`

---

### 6. LSUIElement Not Recognized

**Error:**
```
Unknown key 'LSUIElement'
```

**Cause**: Info.plist not properly configured

**Solution:**

Ensure `Info.plist` has:
```xml
<key>LSUIElement</key>
<true/>
<key>NSPrincipalClass</key>
<string>VimacApp</string>
```

In Xcode:
- Target → Info tab
- Add `LSUIElement` = YES (Boolean)
- Add `Principal class` = `VimacApp` (String)

---

### 7. Cannot Convert CGColor to NSColor

**Error:**
```
Cannot convert value of type 'CGColor' to expected type 'NSColor'
```

**Cause**: Using CGColor where NSColor expected

**Solution:**
```swift
// Wrong:
layer.backgroundColor = NSColor.red.cgColor

// Right:
layer.backgroundColor = NSColor.red.cgColor  // This is correct for CALayer
// OR for NSView:
view.backgroundColor = NSColor.red
```

---

## Runtime Issues

### 1. App Crashes on Launch

**Symptom**: App opens then immediately crashes

**Debug Steps:**
1. Open **Console.app**
2. Filter by "VimacModern"
3. Look for crash logs

**Common Causes:**

**A. Missing Accessibility Permission**
```
Solution: System Settings → Privacy → Accessibility → Add app
```

**B. Nil Unwrapping**
```swift
// Check VimacApp.swift for force unwraps (!)
// Add guard statements:
guard let overlayWindow = overlayWindow else {
    print("❌ Failed to create overlay window")
    return
}
```

**C. Missing Services**
```swift
// In VimacApp, check all services initialized:
print("✅ Services initialized:")
print("  - overlayWindow: \(overlayWindow != nil)")
print("  - appService: \(appService != nil)")
print("  - modeCoordinator: \(modeCoordinator != nil)")
```

---

### 2. Hints Don't Appear

**Symptom**: Press `fd`, nothing happens

**Debug Steps:**

1. **Check Console for:**
```
"🎯 Key sequence matched: fd"
"🎯 Activating hint mode..."
"Found X hintable elements"
```

2. **If no key sequence detected:**
```swift
// KeySequenceListener might not be started
// In VimacApp, verify:
keySequenceListener?.start()
print("✅ Key sequence listener started")
```

3. **If "Found 0 elements":**
```swift
// App might not have accessibility permission
// Or querying wrong window
// Check:
print("Current app: \(currentApp?.localizedName ?? "nil")")
print("Current window: \(currentWindow != nil)")
```

4. **If elements found but no visual hints:**
```swift
// Overlay window might not be visible
// Check:
print("Overlay frame: \(overlayWindow.frame)")
print("Overlay visible: \(overlayWindow.isVisible)")
```

**Solution:**
```swift
// Force overlay to front:
overlayWindow.orderFrontRegardless()
overlayWindow.makeKey()
```

---

### 3. Key Sequences Don't Work

**Symptom**: Typing `fd` or `jk` does nothing

**Possible Causes:**

**A. Input Monitoring Permission**
```
Solution: System Settings → Privacy → Input Monitoring → Add app
```

**B. Event Tap Not Created**
```swift
// Check in Console:
if eventTap == nil {
    print("❌ Event tap failed to create")
    print("   Permission granted: \(PermissionChecker.hasInputMonitoringPermission())")
}
```

**C. Wrong Key Sequence**
```swift
// Check UserDefaults:
let hintShortcut = UserDefaults.standard.string(forKey: "hintModeShortcut") ?? "fd"
print("Hint shortcut: \(hintShortcut)")
// Make sure you're typing the right sequence
```

---

### 4. Settings Window Blank

**Symptom**: Click Settings, window opens but is empty/white

**Cause**: SwiftUI not rendering properly

**Solution:**

1. **Check import:**
```swift
// In SettingsView.swift:
import SwiftUI  // Must be at top
```

2. **Check preview:**
```swift
// Add at bottom:
#Preview {
    SettingsView()
}
```

3. **Force redraw:**
```swift
// In StatusBarManager:
let hostingController = NSHostingController(rootView: SettingsView())
hostingController.view.setFrameSize(NSSize(width: 500, height: 400))
```

---

### 5. Scroll Mode Border Not Visible

**Symptom**: Press `jk`, border should appear but doesn't

**Debug:**
```swift
// In ScrollModeController:
print("🔴 Border frame: \(border.frame)")
print("🔴 Border layer: \(border.layer)")
print("🔴 Border color: \(border.layer?.borderColor)")
```

**Solution:**
```swift
// Make sure border is added and visible:
border.wantsLayer = true
border.layer?.borderWidth = 3.0
border.layer?.borderColor = NSColor.red.cgColor  // Test with red
overlayWindow.contentView?.addSubview(border)
```

---

### 6. Hints Appear in Wrong Position

**Symptom**: Hints don't align with elements

**Cause**: Coordinate conversion issue

**Debug:**
```swift
// In HintPositioning:
print("Element frame (AX): \(element.frame)")
let globalFrame = GeometryUtils.convertAXFrameToGlobal(element.frame)
print("Element frame (Global): \(globalFrame)")
```

**Solution:**
Check multi-screen setup:
```swift
for screen in NSScreen.screens {
    print("Screen: \(screen.frame)")
}
```

---

### 7. App Won't Quit

**Symptom**: Clicking Quit does nothing

**Solution:**

In `StatusBarManager`:
```swift
@objc private func quit() {
    // Clean up
    modeCoordinator?.deactivateCurrentMode()

    // Force quit
    NSApp.terminate(nil)
}
```

---

## Performance Issues

### 1. Slow Hint Display (>1 second)

**Cause**: Too many elements or slow traversal

**Debug:**
```swift
let start = Date()
let elements = queryElements()
let duration = Date().timeIntervalSince(start)
print("⏱️ Query took: \(duration)s for \(elements.count) elements")
```

**Solutions:**

**A. Limit elements:**
```swift
// In QueryWindowService:
let elements = tree.query() ?? []
return Array(elements.prefix(500))  // Cap at 500
```

**B. Timeout queries:**
```swift
// In TraverseElementService:
let timeout: TimeInterval = 1.0  // 1 second max
// Add timeout logic
```

**C. Cache results:**
```swift
private var cachedElements: [Element] = []
private var cacheTime: Date?

func queryElements() -> [Element] {
    // Return cache if < 1 second old
    if let cacheTime = cacheTime,
       Date().timeIntervalSince(cacheTime) < 1.0 {
        return cachedElements
    }

    // Query fresh
    cachedElements = actualQuery()
    self.cacheTime = Date()
    return cachedElements
}
```

---

### 2. Scrolling is Jerky

**Cause**: Timer frequency too low or scroll amount too large

**Solution:**

In `Scroller.swift`:
```swift
// Increase frequency (smoother):
let frequency: TimeInterval = 1.0 / 60.0  // 60 Hz instead of 50 Hz

// Or decrease scroll amount:
let sensitivity = 10  // Instead of 20
```

---

## Debugging Tips

### Enable Verbose Logging

Add to `VimacApp.swift`:
```swift
func applicationDidFinishLaunching(_ notification: Notification) {
    // Debug mode
    UserDefaults.standard.set(true, forKey: "DebugMode")

    // ... rest of code
}

// Then throughout app:
if UserDefaults.standard.bool(forKey: "DebugMode") {
    print("🐛 Debug: \(message)")
}
```

### Use Instruments

```bash
# Profile app:
# 1. Product → Profile (⌘I)
# 2. Choose instrument:
#    - Time Profiler (CPU)
#    - Allocations (Memory)
#    - Leaks (Memory leaks)
```

### Check Accessibility Tree

```swift
// Print element tree:
func printElementTree(_ element: Element, depth: Int = 0) {
    let indent = String(repeating: "  ", count: depth)
    print("\(indent)- \(element.role): \(element.actions)")

    if let children = try? element.children() {
        for child in children {
            printElementTree(child, depth: depth + 1)
        }
    }
}
```

---

## Getting Help

### Before Asking:

1. ✅ Check Console.app logs
2. ✅ Verify permissions granted
3. ✅ Check this document
4. ✅ Read GETTING_STARTED.md
5. ✅ Try clean build (⇧⌘K then ⌘B)

### When Reporting Issues:

Include:
- macOS version
- Xcode version
- Error message (full text)
- Console logs
- Steps to reproduce

---

## Quick Fixes Reference

| Issue | Quick Fix |
|-------|-----------|
| Won't build | Clean build folder (⇧⌘K) |
| Duplicate @main | Keep only VimacApp_Updated.swift |
| AppStorage conflict | Delete custom one, import SwiftUI |
| No hints | Check accessibility permission |
| Keys don't work | Check input monitoring permission |
| Blank settings | Import SwiftUI in SettingsView.swift |
| Wrong position | Check screen frames and coordinates |
| Slow queries | Limit to 500 elements max |

---

**Most issues are permission-related. Always check System Settings → Privacy first!** ✅
