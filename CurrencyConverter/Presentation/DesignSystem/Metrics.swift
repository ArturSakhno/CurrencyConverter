import SwiftUI

/// Theme-independent layout metrics, taken from the Figma layout.
enum DS {
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 20
    }

    enum Radius {
        static let pill: CGFloat = 20
    }

    enum Size {
        static let icon: CGFloat = 24
        static let swapButton: CGFloat = 40
    }

    static let borderWidth: CGFloat = 1.5
}
