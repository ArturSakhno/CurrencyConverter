import SwiftUI

/// Theme-independent layout metrics, taken from the Figma layout.
public enum DS {
    public enum Spacing {
        /// 4
        public static let xxs: CGFloat = 4
        /// 8
        public static let xs: CGFloat = 8
        /// 12
        public static let s: CGFloat = 12
        /// 16
        public static let m: CGFloat = 16
        /// 20
        public static let l: CGFloat = 20
    }

    public enum Radius {
        public static let pill: CGFloat = 20
    }

    public enum Size {
        public static let icon: CGFloat = 24
        public static let swapButton: CGFloat = 40
    }

    public static let borderWidth: CGFloat = 1.5
}
