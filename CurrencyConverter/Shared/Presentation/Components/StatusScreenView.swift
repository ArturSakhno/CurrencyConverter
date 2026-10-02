import DesignSystem
import Foundation
import SwiftUI

struct StatusScreenView: View {
    let systemImage: String
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let isRetrying: Bool
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: DS.Spacing.m) {
            Image(systemName: systemImage)
                .textStyle(.h3)
                .foregroundStyle(DS.Color.iconSecondary)

            Text(title)
                .textStyle(.h4)
                .foregroundStyle(DS.Color.textPrimary)

            Text(message)
                .textStyle(.body)
                .foregroundStyle(DS.Color.textSecondary)

            RetryButton(isRetrying: isRetrying, action: onRetry)
                .padding(.top, DS.Spacing.xs)
        }
        .multilineTextAlignment(.center)
        .padding(DS.Spacing.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .disabled(isRetrying)
    }
}

#if DEBUG
#Preview {
    StatusScreenView(
        systemImage: "wifi.slash",
        title: Localized.Converter.noConnectionTitle,
        message: Localized.Converter.noConnectionMessage,
        isRetrying: false,
        onRetry: {}
    )
}
#endif
