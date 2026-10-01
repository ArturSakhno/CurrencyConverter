import DesignSystem
import SwiftUI

struct ExchangeRateView: View {
    let text: String

    var body: some View {
        Text(text)
            .textStyle(.body)
            .foregroundStyle(DS.Color.interactivePrimary)
            .padding(.horizontal, DS.Spacing.s)
            .padding(.vertical, 11)
            .background(DS.Color.surfaceOverlay, in: .rect(cornerRadius: DS.Radius.pill))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.pill)
                    .stroke(DS.Color.borderDefault, lineWidth: DS.borderWidth)
            )
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
    }
}

#Preview {
    ExchangeRateView(text: "1 USDc = 18.4097 MXN")
}
