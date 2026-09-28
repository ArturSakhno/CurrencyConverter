import SwiftUI

/// A color token resolved at render time against the environment's theme and color
/// scheme, so views write `.foregroundStyle(.textPrimary)` and Light/Dark just works.
public struct ThemeColor: ShapeStyle {
    let token: KeyPath<ColorPalette, Color> & Sendable

    public func resolve(in environment: EnvironmentValues) -> Color {
        environment.theme.palette(for: environment.colorScheme)[keyPath: token]
    }
}

public extension ShapeStyle where Self == ThemeColor {
    nonisolated static var textPrimary: ThemeColor { ThemeColor(token: \.textPrimary) }
    nonisolated static var textSecondary: ThemeColor { ThemeColor(token: \.textSecondary) }
    nonisolated static var textAccent: ThemeColor { ThemeColor(token: \.textAccent) }
    nonisolated static var textError: ThemeColor { ThemeColor(token: \.textError) }

    nonisolated static var bgPrimary: ThemeColor { ThemeColor(token: \.bgPrimary) }
    nonisolated static var bgSelected: ThemeColor { ThemeColor(token: \.bgSelected) }
    nonisolated static var bgOverlay: ThemeColor { ThemeColor(token: \.bgOverlay) }

    nonisolated static var surfaceDefault: ThemeColor { ThemeColor(token: \.surfaceDefault) }
    nonisolated static var surfaceOverlay: ThemeColor { ThemeColor(token: \.surfaceOverlay) }
    nonisolated static var borderDefault: ThemeColor { ThemeColor(token: \.borderDefault) }

    nonisolated static var iconPrimary: ThemeColor { ThemeColor(token: \.iconPrimary) }
    nonisolated static var iconSecondary: ThemeColor { ThemeColor(token: \.iconSecondary) }

    nonisolated static var interactivePrimary: ThemeColor { ThemeColor(token: \.interactivePrimary) }
    nonisolated static var onInteractivePrimary: ThemeColor { ThemeColor(token: \.onInteractivePrimary) }
    nonisolated static var selectorUnselectedBg: ThemeColor { ThemeColor(token: \.selectorUnselectedBg) }
    nonisolated static var selectorUnselectedBorder: ThemeColor { ThemeColor(token: \.selectorUnselectedBorder) }
}
