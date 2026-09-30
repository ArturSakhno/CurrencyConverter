import DesignSystem
import SwiftUI

struct NoConnectionView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: DS.Spacing.m) {
            Image(systemName: "wifi.slash")
                .textStyle(\.h3)
                .foregroundStyle(.iconSecondary)
                .accessibilityHidden(true)

            Text("No connection")
                .textStyle(\.h4)
                .foregroundStyle(.textPrimary)

            Text("Connect to the internet to load exchange rates.")
                .textStyle(\.body)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)

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
        .padding(DS.Spacing.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NoConnectionView {}
}
