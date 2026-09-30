import DesignSystem
import Foundation
import SwiftUI

struct StatusScreenView: View {
    let systemImage: String
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    var isRetrying: Bool = false
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: DS.Spacing.m) {
            Image(systemName: systemImage)
                .textStyle(\.h3)
                .foregroundStyle(.iconSecondary)
                .accessibilityHidden(true)

            Text(title)
                .textStyle(\.h4)
                .foregroundStyle(.textPrimary)

            Text(message)
                .textStyle(\.body)
                .foregroundStyle(.textSecondary)

            Button(action: onRetry) {
                Text(Localized.Common.retry)
                    .textStyle(\.body)
                    .foregroundStyle(.onInteractivePrimary)
                    .opacity(isRetrying ? 0 : 1)
                    .overlay {
                        if isRetrying {
                            ProgressView()
                                .tint(ThemeColor.onInteractivePrimary)
                        }
                    }
                    .padding(.horizontal, DS.Spacing.l)
                    .padding(.vertical, DS.Spacing.s)
                    .background(.interactivePrimary, in: .capsule)
            }
            .padding(.top, DS.Spacing.xs)
        }
        .multilineTextAlignment(.center)
        .padding(DS.Spacing.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .disabled(isRetrying)
    }
}

#Preview {
    StatusScreenView(
        systemImage: "wifi.slash",
        title: Localized.Converter.noConnectionTitle,
        message: Localized.Converter.noConnectionMessage,
        onRetry: {}
    )
}
