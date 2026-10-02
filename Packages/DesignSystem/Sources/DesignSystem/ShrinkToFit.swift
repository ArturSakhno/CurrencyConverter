import SwiftUI

public extension View {
    func shrinkToFit(minimumScale: CGFloat) -> some View {
        modifier(ShrinkToFitModifier(minimumScale: minimumScale))
    }
}

private struct ShrinkToFitModifier: ViewModifier {
    @State private var availableWidth: CGFloat?
    @State private var naturalWidth: CGFloat = 0

    let minimumScale: CGFloat

    func body(content: Content) -> some View {
        content
            .fixedSize()
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
                naturalWidth = width
            }
            .scaleEffect(scale, anchor: .trailing)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
                availableWidth = width
            }
    }
}

private extension ShrinkToFitModifier {
    var scale: CGFloat {
        guard let availableWidth, naturalWidth > 0 else { return 1 }
        return min(1, max(minimumScale, availableWidth / naturalWidth))
    }
}
