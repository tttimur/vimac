# VimacModern

Modern, dependency-free rebuild of Vimac with Tokyo Night aesthetic.

## 🎯 Vision

A minimal, high-performance, Tokyo Night-themed keyboard navigation tool for macOS - inspired by Evangelion's futuristic UI aesthetic.

## ✨ Features

- **Zero External Dependencies** - Pure Swift + native frameworks
- **Tokyo Night Theme** - Sharp rectangular hints with light blue (#7aa2f7) background
- **Modern Architecture** - Swift Concurrency + Combine instead of RxSwift
- **GPU-Ready** - Layer-backed rendering, ready for Metal optimization
- **Native APIs** - Direct Accessibility.framework integration (no AXSwift)
- **macOS 13+ Optimized** - Uses latest ServiceManagement APIs

## 📦 Architecture

```
VimacModern/Sources/
├── App/
│   └── VimacApp.swift                    # Main entry point
│
├── Core/
│   ├── Accessibility/                    # Native accessibility wrapper
│   │   ├── AXAttribute.swift            # Enums (roles, actions, notifications)
│   │   ├── AXElement.swift              # Core wrapper (replaces AXSwift.UIElement)
│   │   ├── AXApplication.swift          # App-level operations + observers
│   │   └── Element.swift                # High-level cached wrapper
│   │
│   ├── Events/                           # Event handling
│   │   ├── EventTap.swift               # CGEventTap + Combine
│   │   ├── Trie.swift                   # Key sequence matching
│   │   ├── InputState.swift             # State machine for sequences
│   │   └── KeySequenceListener.swift    # Combine-based listener
│   │
│   ├── Geometry/
│   │   └── GeometryUtils.swift          # Coordinate transforms
│   │
│   └── Services/
│       ├── MouseActions.swift           # Clicks, movements
│       ├── PermissionChecker.swift      # AX permissions
│       ├── LaunchAtLogin.swift          # Native launch-at-login
│       └── FrontmostApplicationService.swift # App monitoring
│
├── Modes/
│   └── HintMode/
│       └── AlphabetHints.swift          # Hint string generation
│
└── UI/
    ├── Overlays/
    │   ├── OverlayWindow.swift          # Transparent overlay
    │   ├── TokyoNightTheme.swift        # Color palette
    │   └── HintView.swift               # Tokyo Night hint view
    │
    └── Settings/
        └── (TODO: SwiftUI settings)
```

## 🎨 Tokyo Night Color Palette

| Element | Color | Hex |
|---------|-------|-----|
| Hint Background | Light Blue | `#7aa2f7` |
| Untyped Text | Dark | `#1a1b26` |
| Typed Text | Orange | `#ff9e64` |
| Border | Blue-Gray | `#565f89` |
| Glow (optional) | Cyan | `#7dcfff` |

## 🚀 Technology Stack

- **Language**: Swift 5.9+
- **Frameworks**:
  - Cocoa (AppKit)
  - Combine (reactive streams)
  - Accessibility.framework (element queries)
  - CoreGraphics (event tap, rendering)
  - ServiceManagement (launch at login)
- **Minimum macOS**: 13.0 (Ventura)
- **Optimized for**: Apple Silicon (M1/M2/M3)

## 📊 Dependency Elimination

| Old Dependency | Replaced With | Status |
|----------------|---------------|--------|
| AXSwift | Accessibility.framework | ✅ Done |
| RxSwift/RxCocoa | Combine | ✅ Done |
| MASShortcut | CGEventTap | ✅ Done |
| Analytics | Removed | ✅ Done |
| CocoaPods | None | ✅ Done |
| LaunchAtLogin (Carthage) | ServiceManagement | ✅ Done |
| Sparkle | TBD | ⏭️ Next |
| Preferences | SwiftUI | ⏭️ Next |

**Result: 0 external dependencies** 🎉

## 🏗️ Building

### Requirements
- Xcode 15.0+
- macOS 13.0+ SDK
- Swift 5.9+

### Build from Source
```bash
# Create Xcode project (or use Swift Package Manager)
cd VimacModern
swift build  # (once Package.swift is created)
```

## 🎯 Roadmap

### Phase 1: Foundation ✅
- [x] Native Accessibility wrapper
- [x] Event tap system
- [x] Key sequence detection
- [x] Geometry utilities
- [x] Mouse actions
- [x] Launch at login

### Phase 2: UI ✅
- [x] Overlay window
- [x] Tokyo Night theme
- [x] Hint views (sharp rectangles)
- [x] App entry point

### Phase 3: Core Features (In Progress)
- [ ] Hint mode controller
- [ ] Element tree traversal
- [ ] Hint positioning logic
- [ ] Click action execution
- [ ] Scroll mode

### Phase 4: Polish
- [ ] SwiftUI settings window
- [ ] Menu bar integration
- [ ] Performance profiling
- [ ] Metal optimization (if needed)

### Phase 5: Advanced
- [ ] Multi-monitor support
- [ ] Custom hint characters
- [ ] Keyboard layout support
- [ ] Electron app compatibility

## 🎮 Key Sequences (Planned)

- `fd` - Activate hint mode
- `jk` - Alternative hint mode trigger
- `hjkl` - Scroll mode (vim-style)

## 📝 Design Principles

1. **Minimal** - Zero unnecessary dependencies
2. **Fast** - GPU-accelerated rendering, native APIs
3. **Modern** - Latest Swift/macOS features
4. **Clean** - Readable, maintainable code
5. **Styled** - Tokyo Night aesthetic throughout

## 🔧 Development Notes

### Coordinate Systems
- **Accessibility**: Top-left origin
- **Screen**: Bottom-left origin
- Use `GeometryUtils.convertAXFrameToGlobal()` for conversion

### Event Handling
- Uses Combine instead of RxSwift
- EventTap provides `publisher(for:)` method
- KeySequenceListener publishes matched sequences

### Styling
- All UI uses TokyoNightTheme colors
- Sharp rectangular hints (no rounded corners)
- Monospace bold font for consistency
- Optional glow effect (commented out by default)

## 📄 License

MIT License - See LICENSE file

## 🙏 Acknowledgments

- Original Vimac by Dexter Leng
- Homerow (modern successor)
- Vimium browser extension (hint algorithm)
- Tokyo Night color scheme
- Evangelion UI inspiration

---

**Status**: 🚧 Active Development

**Last Updated**: 2025-10-26
