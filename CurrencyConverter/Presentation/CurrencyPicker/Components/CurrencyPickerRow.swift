import SwiftUI

struct CurrencyPickerRow: View {
    let info: CurrencyDisplayInfo
    let isSelected: Bool
    let onSelect: EmptyClosure

    @ScaledMetric(relativeTo: .headline) private var flagSize: CGFloat = 28

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                flag

                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: info.displayCode)
                        .textStyle(\.body)
                        .foregroundStyle(.textPrimary)
                }

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.interactivePrimary)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(Rectangle())
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var flag: some View {
        if let flagAssetName = info.flagAssetName {
            Image(flagAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: flagSize, height: flagSize)
                .clipShape(Circle())
                .accessibilityHidden(true)
        } else {
            Circle()
                .fill(.surfaceDefault)
                .frame(width: flagSize, height: flagSize)
        }
    }
}

#Preview("Selected") {
    CurrencyPickerRow(
        info: .info(for: Currency(code: "MXN")),
        isSelected: true,
        onSelect: {}
    )
    .padding()
}

#Preview("Unselected") {
    CurrencyPickerRow(
        info: .info(for: Currency(code: "EURC")),
        isSelected: false,
        onSelect: {}
    )
    .padding()
}

#Preview("Dark Mode") {
    CurrencyPickerRow(
        info: .info(for: Currency(code: "BRL")),
        isSelected: true,
        onSelect: {}
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Accessibility XXXL") {
    CurrencyPickerRow(
        info: .info(for: Currency(code: "COP")),
        isSelected: false,
        onSelect: {}
    )
    .padding()
    .environment(\.dynamicTypeSize, .accessibility5)
}
