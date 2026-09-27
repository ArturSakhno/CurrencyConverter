import SwiftUI

struct ConverterView: View {
    let dependencies: DependencyContainer
    let coordinator: AppCoordinator
    
    @State private var baseAmountText = "-0"
    @State private var quoteAmountText = "+0"
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            VStack(alignment: .leading, spacing: .zero) {
                Text("Exchange calculator")
                    .padding(.horizontal, 16)
                    .font(.system(size: 32))
                    .fontWeight(.medium)
                
                CurrencyInputField(
                    currencyCode: "USDC",
                    sign: "-",
                    subtitle: "Digital dollars",
                    showsChevron: false,
                    amountText: $baseAmountText,
                    onSelectCurrency: {}
                )
                .padding(.top, 20)
                .padding(.horizontal, 16)
            }
            .padding(.top, 126)
            .overlay(alignment: .bottom) {
                ExchangeRateView()
                    .frame(maxWidth: .infinity)
                    .alignmentGuide(.bottom) { $0[VerticalAlignment.top]
                    }
                    .overlay(alignment: .leading) {
                        SwapButton { }
                            .padding(.leading, 16)
                    }
            }
            .zIndex(1)
            
            .padding(.bottom, 20)
            .background(Color(hex: "#F9F9F9"))
            
            CurrencyInputField(
                currencyCode: "MXN",
                sign: "+",
                subtitle: "Mexican pesos",
                showsChevron: true,
                amountText: $quoteAmountText,
                onSelectCurrency: { coordinator.presentCurrencyPicker() }
            )
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .ignoresSafeArea()
        Spacer()
    }
}

#Preview {
    ConverterView(
        dependencies: .init(),
        coordinator: .init()
    )
}
