import SwiftUI

public extension View {
    func skeleton(_ isActive: Bool) -> some View {
        modifier(SkeletonModifier(isActive: isActive))
    }
}

private struct SkeletonModifier: ViewModifier {
    private enum Pulse {
        static let fullOpacity = 1.0
        static let dimmedOpacity = 0.4
        static let duration = 0.8
    }

    let isActive: Bool

    func body(content: Content) -> some View {
        if isActive {
            content
                .redacted(reason: .placeholder)
                .phaseAnimator([Pulse.fullOpacity, Pulse.dimmedOpacity]) { view, opacity in
                    view.opacity(opacity)
                } animation: { _ in
                    .easeInOut(duration: Pulse.duration)
                }
        } else {
            content
        }
    }
}
