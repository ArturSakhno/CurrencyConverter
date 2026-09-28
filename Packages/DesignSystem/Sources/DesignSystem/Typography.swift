import SwiftUI
import UIKit

/// One Figma text style. Figma's font (Beausite Classic) isn't bundled, so sizes and
/// weights are applied to the system font; swapping the family only touches `font(size:)`.
public struct TextStyle: Sendable, Equatable {
    let size: CGFloat
    let weight: Font.Weight
    /// Figma line height in points; applied as extra line spacing over the font's natural one.
    let lineHeight: CGFloat?
    /// Figma letter spacing, as a percentage of `size` (Figma's "-4" → -4%).
    let trackingPercent: CGFloat
    /// Dynamic Type category the size scales with.
    let relativeTo: Font.TextStyle

    var tracking: CGFloat { size * trackingPercent / 100 }
}

public struct Typography: Sendable, Equatable {
    /// Mobile/Header/H3
    public let h3: TextStyle
    /// Mobile/Header/H4
    public let h4: TextStyle
    /// Mobile/Misc/Amount Input
    public let amountInput: TextStyle
    /// Mobile/Body/Default/Body Default
    public let body: TextStyle
    /// Mobile/Body/Small/Body Small
    public let bodySmall: TextStyle
}

extension Typography {
    static let standard = Typography(
        h3: TextStyle(size: 32, weight: .medium, lineHeight: 36, trackingPercent: -4, relativeTo: .largeTitle),
        h4: TextStyle(size: 24, weight: .medium, lineHeight: 26, trackingPercent: -2, relativeTo: .title),
        // No tracking: `AmountTextField` sizes itself from a hidden `Text` mirroring the
        // `TextField`, and a `TextField` doesn't honor `.tracking`, so the two would drift.
        amountInput: TextStyle(size: 32, weight: .regular, lineHeight: nil, trackingPercent: 0, relativeTo: .largeTitle),
        body: TextStyle(size: 16, weight: .regular, lineHeight: 18, trackingPercent: -1, relativeTo: .body),
        bodySmall: TextStyle(size: 14, weight: .regular, lineHeight: 16, trackingPercent: -1, relativeTo: .subheadline)
    )
}

private struct TextStyleModifier: ViewModifier {
    let style: TextStyle
    @ScaledMetric private var size: CGFloat

    init(style: TextStyle) {
        self.style = style
        _size = ScaledMetric(wrappedValue: style.size, relativeTo: style.relativeTo)
    }

    private var scale: CGFloat { size / style.size }

    private var lineSpacing: CGFloat {
        guard let lineHeight = style.lineHeight else { return 0 }
        let natural = UIFont.systemFont(ofSize: size, weight: style.weight.uiFontWeight).lineHeight
        return max(0, lineHeight * scale - natural)
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: style.weight))
            .tracking(style.tracking * scale)
            .lineSpacing(lineSpacing)
    }
}

private struct ThemedTextStyleModifier: ViewModifier {
    let keyPath: KeyPath<Typography, TextStyle>
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content.modifier(TextStyleModifier(style: theme.typography[keyPath: keyPath]))
    }
}

public extension View {
    /// Applies a text style from the current theme: `.textStyle(\.h3)`.
    func textStyle(_ keyPath: KeyPath<Typography, TextStyle>) -> some View {
        modifier(ThemedTextStyleModifier(keyPath: keyPath))
    }
}

private extension Font.Weight {
    var uiFontWeight: UIFont.Weight {
        switch self {
        case .ultraLight: .ultraLight
        case .thin: .thin
        case .light: .light
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        case .heavy: .heavy
        case .black: .black
        default: .regular
        }
    }
}
