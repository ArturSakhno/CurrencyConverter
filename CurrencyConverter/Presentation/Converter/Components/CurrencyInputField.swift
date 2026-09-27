//
//  CurrencyInputField.swift
//  CurrencyConverter
//
//  Created by Artur Sakhno on 27/09/2026.
//

import SwiftUI

struct CurrencyInputField: View {
    let currencyCode: String
    let sign: String
    let subtitle: String
    let showsChevron: Bool
    @Binding var amountText: String
    let onSelectCurrency: EmptyClosure

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Button {
                    onSelectCurrency()
                } label: {
                    HStack(spacing: .zero) {
                        Text(currencyCode)
                            .font(.system(size: 32, weight: .medium))
                        if showsChevron {
                            Image("chevron.down")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .disabled(!showsChevron)
                .foregroundStyle(.primary)

                Spacer(minLength: 0)

                TextField("", text: $amountText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 32))
            }

            HStack(spacing: 4) {
                Image(systemName: "0.circle")
                    .resizable()
                    .frame(width: 11, height: 11)
                Text(subtitle)
                    .foregroundStyle(Color(hex: "#A8A29F"))
                    .font(.system(size: 14,
                                  weight: .regular))
            }
        }
        .padding(.vertical, 9.5)
    }
}

#Preview {
    @Previewable @State var text = "-0"
    CurrencyInputField(
        currencyCode: "USDC",
        sign: "-",
        subtitle: "Digital dollars",
        showsChevron: true,
        amountText: $text,
        onSelectCurrency: {}
    )
}
