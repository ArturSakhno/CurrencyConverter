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
                .accessibilityHidden(true)

            Text(title)
                .textStyle(.h4)
                .foregroundStyle(DS.Color.textPrimary)

            Text(message)
                .textStyle(.body)
                .foregroundStyle(DS.Color.textSecondary)

            Button(action: onRetry) {
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
        isRetrying: false,
        onRetry: {}
    )
}
