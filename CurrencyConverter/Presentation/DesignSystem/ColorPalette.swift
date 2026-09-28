import SwiftUI

/// Semantic color tokens for one appearance. Names mirror the Figma variables
/// (`text/primary` → `textPrimary`); variables that share a value and meaning are
/// collapsed into one token. Views never use raw colors - see `ThemeColor`.
nonisolated struct ColorPalette: Sendable, Equatable {
    /// text/primary, Labels/Primary
    let textPrimary: Color
    /// text/secondary
    let textSecondary: Color
    /// text/accent-blue-light
    let textAccent: Color
    /// text/error
    let textError: Color

    /// bg/primary
    let bgPrimary: Color
    /// bg/selected
    let bgSelected: Color
    /// bg/overlay
    let bgOverlay: Color

    /// surface/default
    let surfaceDefault: Color
    /// surface/overlay
    let surfaceOverlay: Color
    /// border/default
    let borderDefault: Color

    /// icon/primary
    let iconPrimary: Color
    /// icon/secondary
    let iconSecondary: Color

    /// interactive/primary, button/primary/default/bg, interactive/selector/selected/bg
    let interactivePrimary: Color
    /// button/primary/default/icon, interactive/selector/selected/icon
    let onInteractivePrimary: Color
    /// interactive/selector/unselected/bg
    let selectorUnselectedBg: Color
    /// interactive/selector/unselected/border
    let selectorUnselectedBorder: Color
}

nonisolated extension ColorPalette {
    /// Figma values.
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

    /// Self-designed (Figma is light-only), on the same warm stone scale as the light greys.
    /// The brand green is lifted so it stays visible on a near-black background.
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
