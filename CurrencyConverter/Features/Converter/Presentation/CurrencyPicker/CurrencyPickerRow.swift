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
                    .frame(maxWidth: .infinity, alignment: .leading)

                SelectionIndicator(isSelected: isSelected)
            }
            .contentShape(.rect)
        }
    }

    private var flag: some View {
        ZStack {
            DS.Color.surfaceDefault
                .clipShape(.circle)
            if let flagAssetName = info.flagAssetName {
                Image(flagAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: flagSize, height: flagSize)
                    .clipShape(.circle)
            }
        }
        .frame(width: DS.Size.flagLarge, height: DS.Size.flagLarge)
    }
}

#if DEBUG
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
#endif
