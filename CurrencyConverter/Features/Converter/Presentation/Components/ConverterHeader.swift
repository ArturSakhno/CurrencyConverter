import DesignSystem
import SwiftUI

struct ConverterHeader: View {
    let ratesAsOfText: String?
    let isPlaceholder: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(Localized.Converter.title)
                .padding(.horizontal, DS.Spacing.m)
                .textStyle(.h3)
                .foregroundStyle(DS.Color.textPrimary)

            Text(Localized.Converter.ratesAsOf(ratesAsOfText ?? "00:00"))
                .padding(.horizontal, DS.Spacing.m)
                .textStyle(.bodySmall)
                .foregroundStyle(DS.Color.textSecondary)
                .skeleton(isPlaceholder)
        }
    }
}

#Preview {
    ConverterHeader(ratesAsOfText: "11:24 PM", isPlaceholder: false)
}

#Preview("Placeholder") {
    ConverterHeader(ratesAsOfText: nil, isPlaceholder: true)
}
