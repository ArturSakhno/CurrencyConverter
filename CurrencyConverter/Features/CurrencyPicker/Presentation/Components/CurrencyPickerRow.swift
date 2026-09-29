import DesignSystem
import SwiftUI

struct CurrencyPickerRow: View {
    let info: CurrencyDisplayInfo
    let isSelected: Bool
    let onSelect: EmptyClosure

    @ScaledMetric(relativeTo: .headline) private var flagSize: CGFloat = 24

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: DS.Spacing.s) {
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

                            DS.Icon.checkmark
                                .resizable()
                                .foregroundStyle(.bgPrimary)
                                .accessibilityHidden(true)
                        }
                    } else {
                        Circle()
                            .stroke(
                                .selectorUnselectedBorder,
                                lineWidth: 2
                            )
                    }
                }
                .frame(width: DS.Size.icon, height: DS.Size.icon)
            }
            .contentShape(Rectangle())
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

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
        .frame(width: DS.Size.avatar, height: DS.Size.avatar)
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
