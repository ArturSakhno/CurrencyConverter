import SwiftUI

public extension DS {
    /// Icons shipped in this package's asset catalog, so features don't need their own copies.
    enum Icon {
        public static var arrowDown: Image { image(.dsArrowDown) }
        public static var checkmark: Image { image(.dsCheckmark) }
        public static var chevronDown: Image { image(.dsChevronDown) }
        public static var cross: Image { image(.dsCross) }

        private static func image(_ resource: ImageResource) -> Image {
            Image(resource)
        }
    }
}
