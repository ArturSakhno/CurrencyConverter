import DesignSystem
import SwiftUI

struct CurrencyInputField: View {
    @Binding var amountText: String
    let currencyCode: String
    let sign: String?
    let currencySymbol: String?
    let subtitle: String
    let showsChevron: Bool
    let imageName: String?
    let field: FocusSlot
    var focusedField: FocusState<FocusSlot?>.Binding
    let onSelectCurrency: EmptyClosure

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
            HStack(spacing: DS.Spacing.xxs) {
                Button {
                    onSelectCurrency()
                } label: {
                    HStack(spacing: .zero) {
                        Text(currencyCode)
                            .textStyle(\.h3)
                            .foregroundStyle(.textPrimary)
                        if showsChevron {
                            Image(.dsChevronDown)
                                .resizable()
                                .foregroundStyle(.iconPrimary)
                                .frame(width: DS.Size.icon, height: DS.Size.icon)
                        }
                    }
                    .fixedSize()
                }
                .disabled(!showsChevron)

                AmountTextField(
                    text: $amountText,
                    sign: sign,
                    currencySymbol: currencySymbol,
                    accessibilityLabel: "Amount in \(currencyCode)",
                    field: field,
                    focusedField: focusedField
                )
            }

            HStack(spacing: 4) {
                if let imageName {
                    Image(imageName)
                        .resizable()
                        .frame(width: 11, height: 11)
                }
                Text(subtitle)
                    .textStyle(\.bodySmall)
                    .foregroundStyle(.textSecondary)
            }
        }
        .padding(.vertical, 9.5)
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @FocusState var focusedField: FocusSlot?
    CurrencyInputField(
        amountText: $text,
        currencyCode: "USDC",
        sign: "−",
        currencySymbol: "$",
        subtitle: "Digital dollars",
        showsChevron: true,
        imageName: "us",
        field: .top,
        focusedField: $focusedField,
        onSelectCurrency: {}
    )
}

#Preview("Long amount, SE width") {
    @Previewable @State var shrinks = "12345678.99"
    @Previewable @State var overflows = "338724991234.99"
    @Previewable @FocusState var focusedField: FocusSlot?
    VStack(spacing: 24) {
        CurrencyInputField(
            amountText: $shrinks,
            currencyCode: "USDc",
            sign: "−",
            currencySymbol: "$",
            subtitle: "Digital dollars",
            showsChevron: false,
            imageName: "us",
            field: .top,
            focusedField: $focusedField,
            onSelectCurrency: {}
        )
        CurrencyInputField(
            amountText: $overflows,
            currencyCode: "COP",
            sign: "+",
            currencySymbol: "$",
            subtitle: "Colombian pesos",
            showsChevron: true,
            imageName: "co",
            field: .bottom,
            focusedField: $focusedField,
            onSelectCurrency: {}
        )
    }
    .padding(.horizontal, 16)
    .frame(width: 320)
}
