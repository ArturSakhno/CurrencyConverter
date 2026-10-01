import SwiftUI
import UIKit

public struct TextStyle: Sendable, Equatable {
    let size: CGFloat
    let weight: Font.Weight
    let lineHeight: CGFloat?
    let trackingPercent: CGFloat
    let relativeTo: Font.TextStyle

    var tracking: CGFloat { size * trackingPercent / 100 }
}

public struct Typography: Sendable, Equatable {
    public let h3: TextStyle
    public let h4: TextStyle
    public let amountInput: TextStyle
    public let body: TextStyle
    public let bodySmall: TextStyle
}

extension Typography {
    static let standard = Typography(
        h3: TextStyle(size: 32, weight: .medium, lineHeight: 36, trackingPercent: -4, relativeTo: .largeTitle),
        h4: TextStyle(size: 24, weight: .medium, lineHeight: 26, trackingPercent: -2, relativeTo: .title),
        amountInput: TextStyle(size: 32, weight: .regular, lineHeight: nil, trackingPercent: 0, relativeTo: .largeTitle),
        body: TextStyle(size: 16, weight: .regular, lineHeight: 18, trackingPercent: -1, relativeTo: .body),
        bodySmall: TextStyle(size: 14, weight: .regular, lineHeight: 16, trackingPercent: -1, relativeTo: .subheadline)
    )
}

private struct TextStyleModifier: ViewModifier {
    @ScaledMetric private var size: CGFloat

    let style: TextStyle

    init(style: TextStyle) {
        self.style = style
        _size = ScaledMetric(wrappedValue: style.size, relativeTo: style.relativeTo)
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: style.weight))
            .tracking(style.tracking * scale)
            .lineSpacing(lineSpacing)
    }
}

private extension TextStyleModifier {
    var scale: CGFloat { size / style.size }

    var lineSpacing: CGFloat {
        guard let lineHeight = style.lineHeight else { return 0 }
        let natural = UIFont.systemFont(ofSize: size, weight: style.weight.uiFontWeight).lineHeight
        return max(0, lineHeight * scale - natural)
    }
}

private struct ThemedTextStyleModifier: ViewModifier {
    @Environment(\.theme) private var theme

    let keyPath: KeyPath<Typography, TextStyle>

    func body(content: Content) -> some View {
        content.modifier(TextStyleModifier(style: theme.typography[keyPath: keyPath]))
    }
}

public extension View {
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
