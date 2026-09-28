//
//  ExchangeRateView.swift
//  CurrencyConverter
//
//  Created by Artur Sakhno on 27/09/2026.
//

import SwiftUI

struct ExchangeRateView: View {
    let text: String
    var body: some View {
        Text(text)
            .foregroundStyle(.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "#F5F5F4"), lineWidth: 1.5)
            )
    }
}

#Preview {
    ExchangeRateView(text: "1 USDc = 18.4097 MXN")
}
