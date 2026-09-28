//
//  CurrencyInputField.swift
//  CurrencyConverter
//
//  Created by Artur Sakhno on 27/09/2026.
//

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

    private let spacing: CGFloat = 4

    @State private var rowWidth: CGFloat = 0
    @State private var currencyButtonWidth: CGFloat = 0
    @State private var amountNaturalWidth: CGFloat = 0

    /// Moves the amount onto its own line once it wouldn't fit beside the currency button
    /// even at `AmountTextField.minimumScale` (narrow screens, long converted amounts,
    /// large Dynamic Type). Decided only from widths that don't depend on the current
    /// layout, so switching can't feed back into the decision and oscillate.
    private var isAmountOnOwnLine: Bool {
        guard rowWidth > 0 else { return false }
        let minimumAmountWidth = amountNaturalWidth * AmountTextField.minimumScale
        return currencyButtonWidth + spacing + minimumAmountWidth > rowWidth
    }

    /// `AnyLayout` rather than `if`/`else` or `ViewThatFits`, so the TextField keeps its
    /// identity - and keyboard focus - across the switch.
    private var amountRowLayout: AnyLayout {
        isAmountOnOwnLine
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: spacing))
            : AnyLayout(HStackLayout(spacing: spacing))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            amountRowLayout {
                Button {
                    onSelectCurrency()
                } label: {
                    HStack(spacing: .zero) {
                        Text(currencyCode)
                            .font(.system(size: 32, weight: .medium))
                        if showsChevron {
                            Image(.chevronDown)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .fixedSize()
                }
                .disabled(!showsChevron)
                .foregroundStyle(.primary)
                .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
                    currencyButtonWidth = width
                }

                AmountTextField(
                    text: $amountText,
                    sign: sign,
                    currencySymbol: currencySymbol,
                    accessibilityLabel: "Amount in \(currencyCode)",
                    field: field,
                    focusedField: focusedField,
                    onNaturalWidthChange: { amountNaturalWidth = $0 }
                )
            }

            HStack(spacing: 4) {
                if let imageName {
                    Image(imageName)
                        .resizable()
                        .frame(width: 11, height: 11)
                }
                Text(subtitle)
                    .foregroundStyle(Color(hex: "#A8A29F"))
                    .font(.system(size: 14,
                                  weight: .regular))
            }
        }
        .padding(.vertical, 9.5)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
            rowWidth = width
        }
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
    @Previewable @State var wraps = "338724991234.99"
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
            amountText: $wraps,
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
