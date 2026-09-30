import DesignSystem
import Foundation
import SwiftUI

struct StatusScreenView: View {
    let systemImage: String
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let onRetry: () async -> Void

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

            Button {
                Task {
                    await onRetry()
                }
            } label: {
                Text(Localized.Common.retry)
                    .textStyle(\.body)
                    .foregroundStyle(.onInteractivePrimary)
                    .padding(.horizontal, DS.Spacing.l)
                    .padding(.vertical, DS.Spacing.s)
                    .background(.interactivePrimary, in: .capsule)
            }
            .padding(.top, DS.Spacing.xs)
        }
        .multilineTextAlignment(.center)
        .padding(DS.Spacing.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
