import SwiftUI

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
