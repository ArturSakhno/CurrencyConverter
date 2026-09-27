//
//  ExchangeRateView.swift
//  CurrencyConverter
//
//  Created by Artur Sakhno on 27/09/2026.
//

import SwiftUI

struct ExchangeRateView: View {
    let text: String = "1 USDc = 18.4097 MXN"
    var body: some View {
        Text(text)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "#F5F5F4"), lineWidth: 1.5)
            )
            .backgroundStyle(.white)
    }
}

#Preview {
    ExchangeRateView()
}
