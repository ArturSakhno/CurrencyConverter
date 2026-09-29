import SwiftUI

/// A complete look: one palette per appearance plus typography. Light/Dark comes from the
/// system `colorScheme`; a theme only decides what each appearance looks like.
/// Adding a theme is one more `static let` - inject it with `.theme(_:)`.
public struct Theme: Sendable, Equatable {
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
        light: .standardLight,
        dark: .standardDark,
        typography: .standard
    )
}

extension EnvironmentValues {
    @Entry var theme: Theme = .standard
}

public extension View {
    func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
