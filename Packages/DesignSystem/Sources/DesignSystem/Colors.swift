import SwiftUI
import UIKit

public extension DS {
    enum Color {
        public static let textPrimary = SwiftUI.Color(light: 0x000000, dark: 0xFFFFFF)
        public static let textSecondary = SwiftUI.Color(light: 0xA8A29F, dark: 0xA8A29F)

        public static let bgPrimary = SwiftUI.Color(light: 0xFFFFFF, dark: 0x0C0A09)
        public static let bgSelected = SwiftUI.Color(light: 0xF9F9F9, dark: 0x1C1917)

        public static let surfaceDefault = SwiftUI.Color(light: 0xF5F5F4, dark: 0x292524)
        public static let surfaceOverlay = SwiftUI.Color(light: 0xFFFFFF, dark: 0x1C1917)
        public static let borderDefault = SwiftUI.Color(light: 0xF5F5F4, dark: 0x292524)

        public static let iconPrimary = SwiftUI.Color(light: 0x000000, dark: 0xFFFFFF)
        public static let iconSecondary = SwiftUI.Color(light: 0xA8A29F, dark: 0xA8A29F)

        public static let interactivePrimary = SwiftUI.Color(light: 0x004B2B, dark: 0x1F8A5B)
        public static let onInteractivePrimary = SwiftUI.Color(light: 0xFFFFFF, dark: 0xFFFFFF)
        public static let selectorUnselectedBorder = SwiftUI.Color(light: 0xD6D3D1, dark: 0x44403C)
    }
}

private extension SwiftUI.Color {
    static let redShift: UInt32 = 16
    static let greenShift: UInt32 = 8
    static let channelMask: UInt32 = 0xFF
    static let channelMax: CGFloat = 255

    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            let rgb = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat(rgb >> Self.redShift & Self.channelMask) / Self.channelMax,
                green: CGFloat(rgb >> Self.greenShift & Self.channelMask) / Self.channelMax,
                blue: CGFloat(rgb & Self.channelMask) / Self.channelMax,
                alpha: 1
            )
        })
    }
}
