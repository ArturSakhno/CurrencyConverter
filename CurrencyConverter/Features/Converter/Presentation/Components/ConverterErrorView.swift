import DesignSystem
import SwiftUI

struct ConverterErrorView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: DS.Spacing.m) {
            Image(systemName: "exclamationmark.triangle")
                .textStyle(\.h3)
                .foregroundStyle(.iconSecondary)
                .accessibilityHidden(true)

            Text("Unable to load currencies")
                .textStyle(\.h4)
                .foregroundStyle(.textPrimary)

            Text("Please try again to load the available currencies.")
                .textStyle(\.body)
                .foregroundStyle(.textSecondary)

            Button(action: onRetry) {
                Text("Retry")
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
    ConverterErrorView {}
}
