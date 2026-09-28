import SwiftUI

struct ConverterView: View {
    let dependencies: DependencyContainer
    let coordinator: AppCoordinator
    let quoteCurrency: Currency

    @State private var viewModel: ConverterViewModel
    @State private var baseAmountText = ""
    @State private var quoteAmountText = ""
    /// Only swap toggles this. Drives both row chrome (sign/chevron) and bid vs. ask -
    /// never keyboard focus, which is tracked independently via `focusedSlot`.
    @State private var isBaseOnTop = true
    /// The actual FocusState is keyed by screen slot, not currency - reassigning which
    /// *currency* a slot's `.focused(_:equals:)` claim represents on every swap doesn't
    /// reliably carry focus across the swap in practice. `focusedField` below derives
    /// which currency is logically focused from this plus `isBaseOnTop`.
    @FocusState private var focusedSlot: FocusSlot?
    @Environment(\.scenePhase) private var scenePhase

    init(dependencies: DependencyContainer, coordinator: AppCoordinator, quoteCurrency: Currency) {
        self.dependencies = dependencies
        self.coordinator = coordinator
        self.quoteCurrency = quoteCurrency
        _viewModel = State(wrappedValue: ConverterViewModel(
            convertUseCase: dependencies.convertUseCase,
            loadRatesUseCase: dependencies.loadRatesUseCase
        ))
    }

    private var baseInfo: CurrencyDisplayInfo { .info(for: CurrencyCatalog.base) }
    private var quoteInfo: CurrencyDisplayInfo { .info(for: quoteCurrency) }

    // MARK: - Row identity follows currency, not screen slot

    private var topCurrency: Currency { isBaseOnTop ? CurrencyCatalog.base : quoteCurrency }
    private var bottomCurrency: Currency { isBaseOnTop ? quoteCurrency : CurrencyCatalog.base }
    private var topInfo: CurrencyDisplayInfo { .info(for: topCurrency) }
    private var bottomInfo: CurrencyDisplayInfo { .info(for: bottomCurrency) }
    private var topField: AmountField { isBaseOnTop ? .base : .quote }
    private var bottomField: AmountField { isBaseOnTop ? .quote : .base }

    /// Which currency is logically focused, derived from the slot-stable `focusedSlot`
    /// plus `isBaseOnTop`. Used only to gate the conversion `.onChange` handlers below.
    private var focusedField: AmountField? {
        switch focusedSlot {
        case .top: topField
        case .bottom: bottomField
        case nil: nil
        }
    }

    private var topAmountText: Binding<String> {
        isBaseOnTop ? $baseAmountText : $quoteAmountText
    }

    private var bottomAmountText: Binding<String> {
        isBaseOnTop ? $quoteAmountText : $baseAmountText
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            VStack(alignment: .leading, spacing: .zero) {
                Text("Exchange calculator")
                    .padding(.horizontal, 16)
                    .font(.system(size: 32))
                    .fontWeight(.medium)

                if let ratesAsOfText = viewModel.ratesAsOfText {
                    Text("Rates as of \(ratesAsOfText)")
                        .padding(.horizontal, 16)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                CurrencyInputField(
                    amountText: topAmountText,
                    currencyCode: topInfo.displayCode,
                    sign: "−",
                    currencySymbol: topInfo.currencySymbol,
                    subtitle: topInfo.subtitle,
                    showsChevron: !isBaseOnTop,
                    imageName: topInfo.flagAssetName,
                    field: .top,
                    focusedField: $focusedSlot,
                    onSelectCurrency: { coordinator.presentCurrencyPicker() }
                )
                .padding(.top, 20)
                .padding(.horizontal, 16)
            }
            .padding(.top, 54)
            .overlay(alignment: .bottom) {
                ExchangeRateView(
                    text: viewModel.ratePillText(
                        quoteCurrency: quoteCurrency,
                        isBaseOnTop: isBaseOnTop,
                        baseDisplayCode: baseInfo.displayCode,
                        quoteDisplayCode: quoteInfo.displayCode
                    )
                )
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)
                .alignmentGuide(.bottom) { $0[VerticalAlignment.top]
                }
                .overlay(alignment: .leading) {
                    SwapButton {
                            isBaseOnTop.toggle()
                            // Keep the same *currency* focused (now in the other slot),
                            // not the same slot - only meaningful when something is focused.
                            if focusedSlot != nil {
                                focusedSlot = focusedSlot == .top ? .bottom : .top
                            }
                    }
                    .padding(.leading, 16)
                }
            }
            .zIndex(1)
            .padding(.bottom, 20)
            .background(Color(hex: "#F9F9F9").ignoresSafeArea())
            .task {
                await viewModel.loadRates()
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else { return }
                Task {
                    await viewModel.loadRates()
                }
            }
            .onChange(of: baseAmountText) { _, newValue in
                guard focusedField == .base else { return }
                quoteAmountText = viewModel.convertedAmount(
                    sourceText: newValue,
                    sourceField: .base,
                    quoteCurrency: quoteCurrency,
                    isBaseOnTop: isBaseOnTop
                ) ?? ""
            }
            .onChange(of: quoteAmountText) { _, newValue in
                guard focusedField == .quote else { return }
                baseAmountText = viewModel.convertedAmount(
                    sourceText: newValue,
                    sourceField: .quote,
                    quoteCurrency: quoteCurrency,
                    isBaseOnTop: isBaseOnTop
                ) ?? ""
            }

            CurrencyInputField(
                amountText: bottomAmountText,
                currencyCode: bottomInfo.displayCode,
                sign: "+",
                currencySymbol: bottomInfo.currencySymbol,
                subtitle: bottomInfo.subtitle,
                showsChevron: isBaseOnTop,
                imageName: bottomInfo.flagAssetName,
                field: .bottom,
                focusedField: $focusedSlot,
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
