import SwiftUI
import Testing
@testable import DesignSystem

struct ThemeTests {
    @Test func standardThemePicksPaletteByColorScheme() {
        #expect(Theme.standard.palette(for: .light) == .standardLight)
        #expect(Theme.standard.palette(for: .dark) == .standardDark)
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func themeColorResolvesAgainstEnvironment(colorScheme: ColorScheme) {
        var environment = EnvironmentValues()
        environment.colorScheme = colorScheme

        let expected = Theme.standard.palette(for: colorScheme).interactivePrimary
        #expect(ThemeColor.interactivePrimary.resolve(in: environment) == expected)
    }

    @Test func themeColorResolvesAgainstCustomTheme() {
        var environment = EnvironmentValues()
        environment.colorScheme = .light
        environment.theme = .sample

        #expect(ThemeColor.textPrimary.resolve(in: environment) == Theme.sample.light.textPrimary)
        #expect(ThemeColor.textPrimary.resolve(in: environment) != Theme.standard.light.textPrimary)
    }

    @Test func lightPaletteMatchesFigma() {
        #expect(ColorPalette.standardLight.interactivePrimary == Color(.sRGB, red: 0, green: 75 / 255, blue: 43 / 255))
        #expect(ColorPalette.standardLight.bgSelected == Color(.sRGB, red: 249 / 255, green: 249 / 255, blue: 249 / 255))
    }

    @Test func hexParsesLeadingAlphaForOverlay() {
        // Figma's RGBA #00000080 is written ARGB (#80000000) for `Color(hex:)`.
        #expect(Color(hex: "#80000000") == Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 128 / 255))
    }

    @Test func trackingIsPercentOfSize() {
        #expect(Typography.standard.h3.tracking == -1.28)
        #expect(Typography.standard.amountInput.tracking == 0)
    }
}
