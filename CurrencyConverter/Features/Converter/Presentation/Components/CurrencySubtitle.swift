import DesignSystem
import SwiftUI

struct CurrencySubtitle: View {
    @ScaledMetric(relativeTo: .caption2) private var flagSize: CGFloat = DS.Size.flagSmall

    let imageName: String?
    let text: String

    var body: some View {
        HStack(spacing: DS.Spacing.xxs) {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: flagSize, height: flagSize)
            }
            Text(text)
                .textStyle(.bodySmall)
                .foregroundStyle(DS.Color.textSecondary)
        }
    }
}

#Preview {
    CurrencySubtitle(imageName: "us", text: "Digital dollars")
}

#Preview("Accessibility XXXL") {
    CurrencySubtitle(imageName: "cop", text: "Colombian pesos")
        .environment(\.dynamicTypeSize, .accessibility5)
}
