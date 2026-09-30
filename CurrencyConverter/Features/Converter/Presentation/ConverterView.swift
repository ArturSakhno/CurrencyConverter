import DesignSystem
import SwiftUI

struct ConverterView: View {
    let viewModel: ConverterViewModel
    let baseCurrency: Currency
    let onSelectCurrency: () -> Void

    @FocusState private var focusedSlot: FocusSlot?

    private enum Layout {
        static let screenTop: CGFloat = 54
        static let rowGap: CGFloat = 30
    }

    private enum Sign {
        static let outgoing = "−"
        static let incoming = "+"
    }

    private var isBaseOnTop: Bool { viewModel.isBaseOnTop }
    private var quoteCurrency: Currency { viewModel.quoteCurrency }
    private var baseInfo: CurrencyDisplayInfo { .info(for: baseCurrency) }
    private var quoteInfo: CurrencyDisplayInfo { .info(for: quoteCurrency) }

    private var topCurrency: Currency { isBaseOnTop ? baseCurrency : quoteCurrency }
    private var bottomCurrency: Currency { isBaseOnTop ? quoteCurrency : baseCurrency }
    private var topInfo: CurrencyDisplayInfo { .info(for: topCurrency) }
    private var bottomInfo: CurrencyDisplayInfo { .info(for: bottomCurrency) }
    private var topField: AmountField { isBaseOnTop ? .base : .quote }
    private var bottomField: AmountField { isBaseOnTop ? .quote : .base }

    private func amountText(for field: AmountField) -> Binding<String> {
        Binding(
            get: { viewModel.amountText(for: field) },
            set: { viewModel.setAmountText($0, for: field) }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .zero) {
                VStack(alignment: .leading, spacing: .zero) {
                    Text("Exchange calculator")
                        .padding(.horizontal, DS.Spacing.m)
                        .textStyle(\.h3)
                        .foregroundStyle(.textPrimary)

                    if let ratesAsOfText = viewModel.ratesAsOfText {
                        Text("Rates as of \(ratesAsOfText)")
                            .padding(.horizontal, DS.Spacing.m)
                            .textStyle(\.bodySmall)
                            .foregroundStyle(.textSecondary)
                    }

                    ZStack {
                        VStack {
                            topView
                                .padding(.bottom, Layout.rowGap)

                            bottomView
                                .padding(.top, Layout.rowGap)
                                .background(.bgPrimary)
                        }

                        exchange
                    }
                }
                .padding(.top, Layout.screenTop)
                .background(.bgSelected)
                .task {
                    await viewModel.keepRatesUpdated()
                }

                Spacer(minLength: 0)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(alignment: .top) {
            Rectangle()
                .fill(.bgSelected)
                .ignoresSafeArea(edges: .top)
                .frame(height: .zero)
        }
        .contentShape(.rect)
        .onTapGesture {
            focusedSlot = nil
        }
    }

    var topView: some View {
        CurrencyInputField(
            amountText: amountText(for: topField),
            currencyCode: topInfo.displayCode,
            sign: Sign.outgoing,
            currencySymbol: topInfo.currencySymbol,
            subtitle: topInfo.subtitle,
            showsChevron: !isBaseOnTop,
            imageName: topInfo.flagAssetName,
            field: .top,
            focusedField: $focusedSlot,
            onSelectCurrency: onSelectCurrency
        )
        .padding(.horizontal, DS.Spacing.m)
        .padding(.vertical, DS.Spacing.l)
    }

    var bottomView: some View {
        CurrencyInputField(
            amountText: amountText(for: bottomField),
            currencyCode: bottomInfo.displayCode,
            sign: Sign.incoming,
            currencySymbol: bottomInfo.currencySymbol,
            subtitle: bottomInfo.subtitle,
            showsChevron: isBaseOnTop,
            imageName: bottomInfo.flagAssetName,
            field: .bottom,
            focusedField: $focusedSlot,
            onSelectCurrency: onSelectCurrency
        )
        .padding(.horizontal, DS.Spacing.m)
        .padding(.vertical, DS.Spacing.l)
    }

    var exchange: some View {
        ZStack(alignment: .leading) {
            SwapButton {
                viewModel.swap()
                if focusedSlot != nil {
                    focusedSlot = focusedSlot == .top ? .bottom : .top
                }
            }
            .rotationEffect(isBaseOnTop ? .degrees(0) : .degrees(180))
            .animation(.default, value: isBaseOnTop)
            .padding(.leading, DS.Spacing.m)

            ExchangeRateView(
                text: viewModel.ratePillText(
                    baseDisplayCode: baseInfo.displayCode,
                    quoteDisplayCode: quoteInfo.displayCode
                )
            )
            .frame(maxWidth: .infinity)
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    ConverterView(
        viewModel: DependencyContainer().makeConverterViewModel(),
        baseCurrency: CurrencyCatalog.base,
        onSelectCurrency: {}
    )
}
