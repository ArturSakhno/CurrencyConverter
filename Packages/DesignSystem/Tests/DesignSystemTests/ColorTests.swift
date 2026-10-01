import DesignSystem
import SwiftUI
import Testing

struct ColorTests {
    @Test func lightColorsMatchFigma() {
        #expect(DS.Color.interactivePrimary.rgb(in: .light) == 0x004B2B)
        #expect(DS.Color.bgSelected.rgb(in: .light) == 0xF9F9F9)
    }

    @Test func colorsFollowColorScheme() {
        #expect(DS.Color.textPrimary.rgb(in: .light) == 0x000000)
        #expect(DS.Color.textPrimary.rgb(in: .dark) == 0xFFFFFF)
    }
}

private extension Color {
    func rgb(in colorScheme: ColorScheme) -> UInt32 {
        var environment = EnvironmentValues()
        environment.colorScheme = colorScheme
        let resolved = resolve(in: environment)
        return [resolved.red, resolved.green, resolved.blue]
            .reduce(0) { $0 << 8 | UInt32(($1 * 255).rounded()) }
    }
}
