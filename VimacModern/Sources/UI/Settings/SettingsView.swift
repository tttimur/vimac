//
//  SettingsView.swift
//  VimacModern
//
//  SwiftUI settings window with Tokyo Night styling
//

import SwiftUI

/// Main settings window
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(0)

            HintModeSettingsView()
                .tabItem {
                    Label("Hint Mode", systemImage: "hand.tap")
                }
                .tag(1)

            ScrollModeSettingsView()
                .tabItem {
                    Label("Scroll Mode", systemImage: "scroll")
                }
                .tag(2)

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(3)
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("hintModeShortcut") private var hintModeShortcut = "fd"
    @AppStorage("scrollModeShortcut") private var scrollModeShortcut = "jk"

    var body: some View {
        Form {
            Section(header: Text("Startup")) {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        try? UniversalLaunchAtLogin.setEnabled(newValue)
                    }
            }

            Section(header: Text("Activation")) {
                LabeledContent("Hint Mode") {
                    TextField("Key Sequence", text: $hintModeShortcut)
                        .frame(width: 100)
                }
                LabeledContent("Scroll Mode") {
                    TextField("Key Sequence", text: $scrollModeShortcut)
                        .frame(width: 100)
                }
            }

            Section(header: Text("Permissions")) {
                HStack {
                    Image(systemName: PermissionChecker.hasAccessibilityPermission() ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(PermissionChecker.hasAccessibilityPermission() ? .green : .red)
                    Text("Accessibility Permission")
                    Spacer()
                    if !PermissionChecker.hasAccessibilityPermission() {
                        Button("Grant Permission") {
                            PermissionChecker.requestAccessibilityPermission()
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Hint Mode Settings

struct HintModeSettingsView: View {
    @AppStorage("hintCharacters") private var hintCharacters = "sadfjklewcmpgh"
    @AppStorage("hintFontSize") private var hintFontSize = 11.0

    var body: some View {
        Form {
            Section(header: Text("Hint Appearance")) {
                LabeledContent("Hint Characters") {
                    TextField("Characters", text: $hintCharacters)
                        .frame(width: 200)
                        .help("Characters used to generate hints (e.g., sadfjklewcmpgh)")
                }

                LabeledContent("Font Size") {
                    Slider(value: $hintFontSize, in: 8...16, step: 1) {
                        Text("Font Size")
                    }
                    Text("\(Int(hintFontSize))pt")
                        .frame(width: 40)
                }
            }

            Section(header: Text("Tokyo Night Theme")) {
                ColorRow(label: "Hint Background", color: Color(nsColor: TokyoNightTheme.hintBackground))
                ColorRow(label: "Typed Text", color: Color(nsColor: TokyoNightTheme.hintTextTyped))
                ColorRow(label: "Untyped Text", color: Color(nsColor: TokyoNightTheme.hintTextUntyped))
            }

            Section(header: Text("Behavior")) {
                Text("• Click: Select hint with no modifiers")
                Text("• ⌘ Click: Double click")
                Text("• ⌥ Click: Hover only (no click)")
                Text("• ⌃ Click: Right click")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Scroll Mode Settings

struct ScrollModeSettingsView: View {
    @AppStorage("scrollSensitivity") private var scrollSensitivity = 20.0
    @AppStorage("reverseHorizontal") private var reverseHorizontal = false
    @AppStorage("reverseVertical") private var reverseVertical = false

    var body: some View {
        Form {
            Section(header: Text("Scroll Behavior")) {
                LabeledContent("Sensitivity") {
                    Slider(value: $scrollSensitivity, in: 1...50, step: 1) {
                        Text("Sensitivity")
                    }
                    Text("\(Int(scrollSensitivity))")
                        .frame(width: 40)
                }

                Toggle("Reverse Horizontal", isOn: $reverseHorizontal)
                Toggle("Reverse Vertical", isOn: $reverseVertical)
            }

            Section(header: Text("Key Bindings")) {
                Text("• h: Scroll left")
                Text("• j: Scroll down")
                Text("• k: Scroll up")
                Text("• l: Scroll right")
                Text("• g: Scroll to top")
                Text("• G: Scroll to bottom")
                Text("• Esc: Exit scroll mode")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - About

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("VimacModern")
                .font(.title)
                .fontWeight(.bold)

            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Modern, dependency-free keyboard navigation for macOS")
                .multilineTextAlignment(.center)
                .padding()

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                InfoRow(label: "Dependencies", value: "0 ✨")
                InfoRow(label: "Tech Stack", value: "Swift + Combine")
                InfoRow(label: "Theme", value: "Tokyo Night")
                InfoRow(label: "Architecture", value: "Native macOS")
            }

            Spacer()

            HStack(spacing: 20) {
                Link("GitHub", destination: URL(string: "https://github.com/tttimur/vimac")!)
                Text("•")
                    .foregroundColor(.secondary)
                Link("Report Issue", destination: URL(string: "https://github.com/tttimur/vimac/issues")!)
            }
            .font(.caption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Helper Views

struct ColorRow: View {
    let label: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 60, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
