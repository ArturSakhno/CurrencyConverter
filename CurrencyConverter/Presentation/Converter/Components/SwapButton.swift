//
//  SwapButton.swift
//  CurrencyConverter
//
//  Created by Artur Sakhno on 27/09/2026.
//

import SwiftUI

struct SwapButton: View {
    let action: EmptyClosure
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color(hex: "#004B2B"))
                Image("arrow.down")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .frame(width: 40, height: 40)
        }

    }
}

#Preview {
    SwapButton {
        
    }
}
