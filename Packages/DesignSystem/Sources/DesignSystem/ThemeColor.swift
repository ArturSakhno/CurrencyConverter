import SwiftUI

public struct ThemeColor: ShapeStyle {
    let token: KeyPath<ColorPalette, Color> & Sendable

    public func resolve(in environment: EnvironmentValues) -> Color {
        environment.theme.palette(for: environment.colorScheme)[keyPath: token]
    }
}

public extension ShapeStyle where Self == ThemeColor {
    static var textPrimary: ThemeColor { ThemeColor(token: \.textPrimary) }
    static var textSecondary: ThemeColor { ThemeColor(token: \.textSecondary) }
    static var textAccent: ThemeColor { ThemeColor(token: \.textAccent) }
    static var textError: ThemeColor { ThemeColor(token: \.textError) }

    static var bgPrimary: ThemeColor { ThemeColor(token: \.bgPrimary) }
    static var bgSelected: ThemeColor { ThemeColor(token: \.bgSelected) }
    static var bgOverlay: ThemeColor { ThemeColor(token: \.bgOverlay) }

    static var surfaceDefault: ThemeColor { ThemeColor(token: \.surfaceDefault) }
    static var surfaceOverlay: ThemeColor { ThemeColor(token: \.surfaceOverlay) }
    static var borderDefault: ThemeColor { ThemeColor(token: \.borderDefault) }

    static var iconPrimary: ThemeColor { ThemeColor(token: \.iconPrimary) }
    static var iconSecondary: ThemeColor { ThemeColor(token: \.iconSecondary) }

    static var interactivePrimary: ThemeColor { ThemeColor(token: \.interactivePrimary) }
    static var onInteractivePrimary: ThemeColor { ThemeColor(token: \.onInteractivePrimary) }
    static var selectorUnselectedBg: ThemeColor { ThemeColor(token: \.selectorUnselectedBg) }
    static var selectorUnselectedBorder: ThemeColor { ThemeColor(token: \.selectorUnselectedBorder) }
}
