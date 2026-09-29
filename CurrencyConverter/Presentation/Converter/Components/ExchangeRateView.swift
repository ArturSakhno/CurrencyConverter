import DesignSystem
import SwiftUI

struct ExchangeRateView: View {
    let text: String
    var body: some View {
        Text(text)
            .textStyle(\.body)
            .foregroundStyle(.interactivePrimary)
            .padding(.horizontal, DS.Spacing.s)
            .padding(.vertical, 11)
            .background(.surfaceOverlay, in: .rect(cornerRadius: DS.Radius.pill))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.pill)
                    .stroke(.borderDefault, lineWidth: DS.borderWidth)
            )
    }
}

#Preview {
    ExchangeRateView(text: "1 USDc = 18.4097 MXN")
}

#Preview("Dark Mode") {
    ExchangeRateView(text: "1 USDc = 18.4097 MXN")
        .preferredColorScheme(.dark)
}

#Preview("Sample theme") {
    ExchangeRateView(text: "1 USDc = 18.4097 MXN")
        .theme(.sample)
}
