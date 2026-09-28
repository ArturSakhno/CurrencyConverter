import SwiftUI

/// A complete look: one palette per appearance plus typography. Light/Dark comes from the
/// system `colorScheme`; a theme only decides what each appearance looks like.
/// Adding a theme is one more `static let` - inject it with `.theme(_:)`.
public struct Theme: Sendable, Equatable {
    let name: String
    let light: ColorPalette
    let dark: ColorPalette
    let typography: Typography

    func palette(for colorScheme: ColorScheme) -> ColorPalette {
        switch colorScheme {
        case .dark: dark
        default: light
        }
    }
}

public extension Theme {
    static let standard = Theme(
        name: "Standard",
        light: .standardLight,
        dark: .standardDark,
        typography: .standard
    )
}

// Hand-written key rather than `@Entry`: the macro's key conformance would be
// MainActor-isolated under this target's default isolation, and `ThemeColor.resolve`
// reads the theme from a nonisolated context.
private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .standard
}

extension EnvironmentValues {
    nonisolated var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

public extension View {
    func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
