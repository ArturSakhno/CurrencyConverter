import SwiftUI

public struct TextStyle: Sendable {
    let size: CGFloat
    let weight: Font.Weight
    let relativeTo: Font.TextStyle
}

public extension TextStyle {
    static let h3 = TextStyle(size: 32, weight: .medium, relativeTo: .largeTitle)
    static let h4 = TextStyle(size: 24, weight: .medium, relativeTo: .title)
    static let amountInput = TextStyle(size: 32, weight: .regular, relativeTo: .largeTitle)
    static let body = TextStyle(size: 16, weight: .regular, relativeTo: .body)
    static let bodySmall = TextStyle(size: 14, weight: .regular, relativeTo: .subheadline)
}

private struct TextStyleModifier: ViewModifier {
    @ScaledMetric private var size: CGFloat

    let style: TextStyle

    init(style: TextStyle) {
        self.style = style
        _size = ScaledMetric(wrappedValue: style.size, relativeTo: style.relativeTo)
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: style.weight))
    }
}

public extension View {
    func textStyle(_ style: TextStyle) -> some View {
        modifier(TextStyleModifier(style: style))
    }
}
