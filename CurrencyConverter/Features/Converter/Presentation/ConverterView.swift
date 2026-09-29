import DesignSystem
import SwiftUI

struct ConverterView: View {
    let viewModel: ConverterViewModel
    let baseCurrency: Currency
    let onSelectCurrency: EmptyClosure

    /// Keyed by screen slot, not currency - reassigning which *currency* a slot's
    /// `.focused(_:equals:)` claim represents on every swap doesn't reliably carry focus
    /// across the swap in practice.
    @FocusState private var focusedSlot: FocusSlot?
    @Environment(\.scenePhase) private var scenePhase

    /// Screen-specific metrics from the Figma layout (not reusable design tokens).
    private enum Layout {
        static let screenTop: CGFloat = 54
        /// Half the swap button's height, so the button and rate pill straddle both rows.
        static let rowGap: CGFloat = 30
    }

    /// Top row sells (money leaves), bottom row buys - see the bid/ask rule in the view model.
    private enum Sign {
        static let outgoing = "−"
        static let incoming = "+"
    }

    private var isBaseOnTop: Bool { viewModel.isBaseOnTop }
    private var quoteCurrency: Currency { viewModel.quoteCurrency }
    private var baseInfo: CurrencyDisplayInfo { .info(for: baseCurrency) }
    private var quoteInfo: CurrencyDisplayInfo { .info(for: quoteCurrency) }

    // MARK: - Row identity follows currency, not screen slot

    private var topCurrency: Currency { isBaseOnTop ? baseCurrency : quoteCurrency }
    private var bottomCurrency: Currency { isBaseOnTop ? quoteCurrency : baseCurrency }
    private var topInfo: CurrencyDisplayInfo { .info(for: topCurrency) }
    private var bottomInfo: CurrencyDisplayInfo { .info(for: bottomCurrency) }
    private var topField: AmountField { isBaseOnTop ? .base : .quote }
    private var bottomField: AmountField { isBaseOnTop ? .quote : .base }

    /// Only the text field writes through this, so every `set` is a user edit.
    private func amountText(for field: AmountField) -> Binding<String> {
        Binding(
            get: { viewModel.amountText(for: field) },
            set: { viewModel.setAmountText($0, for: field) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            VStack(alignment: .leading, spacing: .zero) {
                Text("Exchange calculator", comment: "Main screen title")
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
                await viewModel.loadRates()
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else { return }
                Task {
                    await viewModel.loadRates()
                }
            }

            Spacer(minLength: 0)
        }
        // Tapping anywhere outside the fields - including the empty area below - dismisses the keyboard.
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
                // Keep the same *currency* focused (now in the other slot),
                // not the same slot - only meaningful when something is focused.
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
