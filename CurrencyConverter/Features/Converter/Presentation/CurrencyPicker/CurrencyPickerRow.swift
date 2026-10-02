import DesignSystem
import SwiftUI

struct CurrencyPickerRow: View {
    @ScaledMetric(relativeTo: .largeTitle) private var flagSize: CGFloat = DS.Size.flagMedium

    let info: CurrencyDisplayInfo
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: DS.Spacing.xs) {
                flag

                Text(verbatim: info.displayCode)
                    .textStyle(.body)
                    .foregroundStyle(DS.Color.textPrimary)

                Spacer(minLength: DS.Spacing.xs)

                SelectionIndicator(isSelected: isSelected)
            }
            .contentShape(Rectangle())
        }
    }
}

private extension CurrencyPickerRow {
    var flag: some View {
        ZStack {
            Circle()
                .fill(DS.Color.surfaceDefault)
            if let flagAssetName = info.flagAssetName {
                Image(flagAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: flagSize, height: flagSize)
                    .clipShape(Circle())
            }
        }
        .frame(width: DS.Size.flagLarge, height: DS.Size.flagLarge)
    }
}

#Preview("Selected") {
    CurrencyPickerRow(
        info: .info(for: Currency(code: "MXN")),
        isSelected: true,
        onSelect: {}
    )
    .padding(DS.Spacing.m)
}

#Preview("Unselected") {
    CurrencyPickerRow(
        info: .info(for: Currency(code: "EURC")),
        isSelected: false,
        onSelect: {}
    )
    .padding(DS.Spacing.m)
}

#Preview("Accessibility XXXL") {
    CurrencyPickerRow(
        info: .info(for: Currency(code: "COP")),
        isSelected: false,
        onSelect: {}
    )
    .padding(DS.Spacing.m)
    .environment(\.dynamicTypeSize, .accessibility5)
}
