import DesignSystem
import SwiftUI

struct RetryButton: View {
    let isRetrying: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(Localized.Common.retry)
                .textStyle(.body)
                .foregroundStyle(DS.Color.onInteractivePrimary)
                .opacity(isRetrying ? 0 : 1)
                .overlay {
                    if isRetrying {
                        ProgressView()
                            .tint(DS.Color.onInteractivePrimary)
                    }
                }
                .padding(.horizontal, DS.Spacing.l)
                .padding(.vertical, DS.Spacing.s)
                .background(DS.Color.interactivePrimary, in: .capsule)
        }
    }
}

#Preview("Idle") {
    RetryButton(isRetrying: false) {}
}

#Preview("Retrying") {
    RetryButton(isRetrying: true) {}
}
