//
//  HintView.swift
//  VimacModern
//
//  Tokyo Night themed hint view - sharp rectangular, futuristic
//  Pure AppKit with layer-backed rendering
//

import Cocoa

/// Modern hint view with Tokyo Night styling
class HintView: NSView {
    let associatedElement: Element
    private var textField: HintTextField

    // Sharp rectangular design (no rounded corners)
    private let borderWidth: CGFloat = 1.0
    private let cornerRadius: CGFloat = 0.0 // Sharp rectangles!

    init(element: Element, text: String, typedText: String = "", fontSize: CGFloat = 11) {
        self.associatedElement = element
        self.textField = HintTextField(text: text, typedText: typedText, fontSize: fontSize)

        super.init(frame: .zero)

        // Add text field
        self.addSubview(textField)

        // Layer-backed view for GPU acceleration
        self.wantsLayer = true

        // Tokyo Night styling
        self.layer?.backgroundColor = TokyoNightTheme.hintBackground.cgColor
        self.layer?.borderColor = TokyoNightTheme.border.cgColor
        self.layer?.borderWidth = borderWidth
        self.layer?.cornerRadius = cornerRadius // Sharp edges

        // Optional: Add subtle glow for futuristic feel
        // Uncomment to enable:
        // self.layer?.shadowColor = TokyoNightTheme.glow.cgColor
        // self.layer?.shadowRadius = 4
        // self.layer?.shadowOpacity = 1.0
        // self.layer?.shadowOffset = .zero

        // Auto layout
        self.translatesAutoresizingMaskIntoConstraints = false
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    private func setupConstraints() {
        // Center text field
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            // Size based on text + padding
            self.widthAnchor.constraint(equalToConstant: width()),
            self.heightAnchor.constraint(equalToConstant: height())
        ])
    }

    private func width() -> CGFloat {
        return textField.intrinsicContentSize.width + (2 * borderWidth) + 8 // Extra padding
    }

    private func height() -> CGFloat {
        return textField.intrinsicContentSize.height + (2 * borderWidth) + 4 // Extra padding
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: width(), height: height())
    }

    /// Update the typed portion of the hint text
    func updateTypedText(_ typed: String) {
        textField.updateTypedText(typed)
    }
}

// MARK: - Hint Text Field

/// Text field for displaying hint text with typed/untyped highlighting
private class HintTextField: NSTextField {
    private let fullText: String
    private let fontSize: CGFloat

    init(text: String, typedText: String, fontSize: CGFloat) {
        self.fullText = text
        self.fontSize = fontSize

        super.init(frame: .zero)

        // Setup appearance
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isBezeled = false
        self.drawsBackground = false
        self.isEditable = false
        self.isSelectable = false

        // Monospace font for consistent hint sizing
        self.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .bold)

        // Layer-backed for crisp rendering
        self.wantsLayer = true
        self.canDrawSubviewsIntoLayer = true

        // Set initial text
        updateTypedText(typedText)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    func updateTypedText(_ typed: String) {
        let attributedString = NSMutableAttributedString(string: fullText)
        let fullRange = NSRange(location: 0, length: fullText.count)

        // Default: untyped color
        attributedString.addAttribute(
            .foregroundColor,
            value: TokyoNightTheme.hintTextUntyped,
            range: fullRange
        )

        // Highlight typed portion
        if fullText.lowercased().hasPrefix(typed.lowercased()), !typed.isEmpty {
            let typedRange = NSRange(location: 0, length: min(typed.count, fullText.count))
            attributedString.addAttribute(
                .foregroundColor,
                value: TokyoNightTheme.hintTextTyped,
                range: typedRange
            )
        }

        self.attributedStringValue = attributedString
    }
}
