import SwiftUI

struct CurrencyPickerRow: View {
    let info: CurrencyDisplayInfo
    let isSelected: Bool
    let onSelect: EmptyClosure

    @ScaledMetric(relativeTo: .headline) private var flagSize: CGFloat = 24

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                flag

                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: info.displayCode)
                        .textStyle(\.body)
                        .foregroundStyle(.textPrimary)
                }

                Spacer()

                Group {
                    if isSelected {
                        ZStack {
                            Circle()
                                .fill(.interactivePrimary)

                            Image(.checkmark)
                                .resizable()
                                .foregroundStyle(.bgPrimary)
                                .accessibilityHidden(true)
                        }
                    } else {
                        Circle()
                            .stroke(.selectorUnselectedBorder,
                                    lineWidth: 2)
                    }
                }
                .frame(width: DS.Size.icon, height: DS.Size.icon)
            }
            .contentShape(Rectangle())
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var flag: some View {
        ZStack {
            Circle()
                .fill(.surfaceDefault)
            if let flagAssetName = info.flagAssetName {
                Image(flagAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: flagSize, height: flagSize)
                    .clipShape(Circle())
                    .accessibilityHidden(true)
            }
        }
        .frame(width: 40, height: 40)
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
