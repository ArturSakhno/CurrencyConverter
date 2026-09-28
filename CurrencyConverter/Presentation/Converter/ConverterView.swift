import SwiftUI

struct ConverterView: View {
    let dependencies: DependencyContainer
    let coordinator: AppCoordinator
    let quoteCurrency: Currency

    @State private var baseAmountText = ""
    @State private var quoteAmountText = ""

    private var baseInfo: CurrencyDisplayInfo { .info(for: CurrencyCatalog.base) }
    private var quoteInfo: CurrencyDisplayInfo { .info(for: quoteCurrency) }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            VStack(alignment: .leading, spacing: .zero) {
                Text("Exchange calculator")
                    .padding(.horizontal, 16)
                    .font(.system(size: 32))
                    .fontWeight(.medium)
                
                CurrencyInputField(
                    amountText: $baseAmountText,
                    currencyCode: baseInfo.displayCode,
                    sign: "−",
                    currencySymbol: baseInfo.currencySymbol,
                    subtitle: baseInfo.subtitle,
                    showsChevron: false,
                    imageName: baseInfo.flagAssetName,
                    onSelectCurrency: {}
                )
                .padding(.top, 20)
                .padding(.horizontal, 16)
            }
            .padding(.top, 54)
            .overlay(alignment: .bottom) {
                ExchangeRateView()
                    .frame(maxWidth: .infinity)
                    .allowsHitTesting(false)
                    .alignmentGuide(.bottom) { $0[VerticalAlignment.top]
                    }
                    .overlay(alignment: .leading) {
                        SwapButton { }
                            .padding(.leading, 16)
                    }
            }
            .zIndex(1)
            
            .padding(.bottom, 20)
            .background(Color(hex: "#F9F9F9").ignoresSafeArea())
            
            CurrencyInputField(
                amountText: $quoteAmountText,
                currencyCode: quoteInfo.displayCode,
                sign: "+",
                currencySymbol: quoteInfo.currencySymbol,
                subtitle: quoteInfo.subtitle,
                showsChevron: true,
                imageName: quoteInfo.flagAssetName,
                onSelectCurrency: { coordinator.presentCurrencyPicker() }
            )
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        
        Spacer()
    }
}

#Preview {
    ConverterView(
        dependencies: .init(),
        coordinator: .init(),
        quoteCurrency: CurrencyCatalog.defaultQuote
    )
}
