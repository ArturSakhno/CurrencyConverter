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
    let focusedField: FocusState<FocusSlot?>.Binding
    let onSelectCurrency: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
            HStack(spacing: DS.Spacing.xxs) {
                CurrencyCodeButton(
                    code: currencyCode,
                    showsChevron: showsChevron,
                    action: onSelectCurrency
                )

                AmountTextField(
                    text: $amountText,
                    sign: sign,
                    currencySymbol: currencySymbol,
                    field: field,
                    focusedField: focusedField
                )
            }

            CurrencySubtitle(imageName: imageName, text: subtitle)
        }
        .padding(.vertical, DS.Spacing.inputFieldVertical)
    }
}

#if DEBUG
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
            imageName: "cop",
            field: .bottom,
            focusedField: $focusedField,
            onSelectCurrency: {}
        )
    }
    .padding(.horizontal, DS.Spacing.m)
    .frame(width: 320)
}
#endif
