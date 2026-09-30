import SwiftUI

struct ColorPalette: Sendable, Equatable {
    let textPrimary: Color
    let textSecondary: Color
    let textAccent: Color
    let textError: Color

    let bgPrimary: Color
    let bgSelected: Color
    let bgOverlay: Color

    let surfaceDefault: Color
    let surfaceOverlay: Color
    let borderDefault: Color

    let iconPrimary: Color
    let iconSecondary: Color

    let interactivePrimary: Color
    let onInteractivePrimary: Color
    let selectorUnselectedBg: Color
    let selectorUnselectedBorder: Color
}

extension ColorPalette {
    static let standardLight = ColorPalette(
        textPrimary: Color(hex: "#000000"),
        textSecondary: Color(hex: "#A8A29F"),
        textAccent: Color(hex: "#3C96CF"),
        textError: Color(hex: "#F35A27"),
        bgPrimary: Color(hex: "#FFFFFF"),
        bgSelected: Color(hex: "#F9F9F9"),
        bgOverlay: Color(hex: "#80000000"),
        surfaceDefault: Color(hex: "#F5F5F4"),
        surfaceOverlay: Color(hex: "#FFFFFF"),
        borderDefault: Color(hex: "#F5F5F4"),
        iconPrimary: Color(hex: "#000000"),
        iconSecondary: Color(hex: "#A8A29F"),
        interactivePrimary: Color(hex: "#004B2B"),
        onInteractivePrimary: Color(hex: "#FFFFFF"),
        selectorUnselectedBg: Color(hex: "#FFFFFF"),
        selectorUnselectedBorder: Color(hex: "#D6D3D1")
    )

    static let standardDark = ColorPalette(
        textPrimary: Color(hex: "#FFFFFF"),
        textSecondary: Color(hex: "#A8A29F"),
        textAccent: Color(hex: "#5AAEE0"),
        textError: Color(hex: "#FF7A4D"),
        bgPrimary: Color(hex: "#0C0A09"),
        bgSelected: Color(hex: "#1C1917"),
        bgOverlay: Color(hex: "#B3000000"),
        surfaceDefault: Color(hex: "#292524"),
        surfaceOverlay: Color(hex: "#1C1917"),
        borderDefault: Color(hex: "#292524"),
        iconPrimary: Color(hex: "#FFFFFF"),
        iconSecondary: Color(hex: "#A8A29F"),
        interactivePrimary: Color(hex: "#1F8A5B"),
        onInteractivePrimary: Color(hex: "#FFFFFF"),
        selectorUnselectedBg: Color(hex: "#1C1917"),
        selectorUnselectedBorder: Color(hex: "#44403C")
    )
}
