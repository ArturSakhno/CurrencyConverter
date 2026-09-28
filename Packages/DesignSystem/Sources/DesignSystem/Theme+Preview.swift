#if DEBUG
import SwiftUI

public extension Theme {
    /// Sample custom theme proving the system takes more than Light/Dark.
    /// Not shipped - previews and tests only.
    nonisolated static let sample = Theme(
        name: "Sample",
        light: ColorPalette(
            textPrimary: Color(hex: "#1E1B4B"),
            textSecondary: Color(hex: "#6B7280"),
            textAccent: Color(hex: "#7C3AED"),
            textError: Color(hex: "#DC2626"),
            bgPrimary: Color(hex: "#FFFFFF"),
            bgSelected: Color(hex: "#EEF2FF"),
            bgOverlay: Color(hex: "#801E1B4B"),
            surfaceDefault: Color(hex: "#E0E7FF"),
            surfaceOverlay: Color(hex: "#FFFFFF"),
            borderDefault: Color(hex: "#C7D2FE"),
            iconPrimary: Color(hex: "#1E1B4B"),
            iconSecondary: Color(hex: "#6B7280"),
            interactivePrimary: Color(hex: "#4F46E5"),
            onInteractivePrimary: Color(hex: "#FFFFFF"),
            selectorUnselectedBg: Color(hex: "#FFFFFF"),
            selectorUnselectedBorder: Color(hex: "#C7D2FE")
        ),
        dark: .standardDark,
        typography: .standard
    )
}
#endif
