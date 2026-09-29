import SwiftUI

public extension DS {
    /// Icons shipped in this package's asset catalog, so features don't need their own copies.
    enum Icon {
        public static var arrowDown: Image { image("ds.arrow.down") }
        public static var checkmark: Image { image("ds.checkmark") }
        public static var chevronDown: Image { image("ds.chevron.down") }
        public static var cross: Image { image("ds.cross") }

        private static func image(_ name: String) -> Image {
            Image(name, bundle: .module)
        }
    }
}
