import DesignSystem
import SwiftUI

struct ConverterView: View {
    private enum Sign {
        static let outgoing = "−"
        static let incoming = "+"
    }

    @FocusState private var focusedSlot: FocusSlot?

    let viewModel: ConverterViewModel
    let quoteCurrency: Currency
    let isPlaceholder: Bool
    let onSelectCurrency: () -> Void

    private let placeholderAmount = "0.00"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.zero) {
                VStack(alignment: .leading, spacing: DS.Spacing.zero) {
                    ConverterHeader(
                        ratesAsOfText: viewModel.ratesAsOfText,
                        isPlaceholder: isPlaceholder
                    )

                    ZStack {
                        rows
                        exchange
                    }
                }
                .padding(.top, DS.Spacing.screenTop)
                .background(DS.Color.bgSelected)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(alignment: .top) {
            statusBarBackground
        }
        .contentShape(.rect)
        .onTapGesture {
            focusedSlot = nil
        }
    }

    private var statusBarBackground: some View {
        DS.Color.bgSelected
            .clipShape(.rect)
            .ignoresSafeArea(edges: .top)
            .frame(height: .zero)
    }

    private var rows: some View {
        VStack(spacing: DS.Spacing.xs) {
            row(.top)
                .containerShape(.rect)
                .skeleton(isPlaceholder)
                .padding(.bottom, DS.Spacing.converterRowGap)

            row(.bottom)
                .skeleton(isPlaceholder)
                .padding(.top, DS.Spacing.converterRowGap)
                .background(DS.Color.bgPrimary)
        }
    }

    private var exchange: some View {
        ZStack(alignment: .leading) {
            SwapButton {
                swapRows()
            }
            .rotationEffect(viewModel.isBaseOnTop ? .zero : .degrees(180))
            .animation(.default, value: viewModel.isBaseOnTop)
            .padding(.leading, DS.Spacing.m)

            ExchangeRateView(text: rateText)
                .skeleton(isPlaceholder)
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)
        }
    }

    private var rateText: String {
        viewModel.ratePillText(
            baseDisplayCode: CurrencyDisplayInfo.info(for: viewModel.baseCurrency).displayCode,
            quoteDisplayCode: CurrencyDisplayInfo.info(for: quoteCurrency).displayCode
        )
    }
}

private extension ConverterView {
    func row(_ slot: FocusSlot) -> some View {
        let field = amountField(in: slot)
        let currency = isPlaceholder || field == .base ? viewModel.baseCurrency : quoteCurrency
        let info = CurrencyDisplayInfo.info(for: currency)
        return CurrencyInputField(
            amountText: amountText(for: field),
            currencyCode: info.displayCode,
            sign: isPlaceholder ? nil : sign(for: slot),
            currencySymbol: isPlaceholder ? nil : info.currencySymbol,
            subtitle: info.subtitle,
            showsChevron: !isPlaceholder && field == .quote,
            imageName: info.flagAssetName,
            field: slot,
            focusedField: $focusedSlot,
            onSelectCurrency: isPlaceholder ? {} : onSelectCurrency
        )
        .padding(.horizontal, DS.Spacing.m)
        .padding(.vertical, DS.Spacing.l)
        .contentShape(.rect)
        .onTapGesture {
            focusedSlot = slot
        }
    }

    func amountField(in slot: FocusSlot) -> AmountField {
        (slot == .top) == viewModel.isBaseOnTop ? .base : .quote
    }

    func sign(for slot: FocusSlot) -> String {
        slot == .top ? Sign.outgoing : Sign.incoming
    }

    func amountText(for field: AmountField) -> Binding<String> {
        guard !isPlaceholder else { return .constant(placeholderAmount) }
        return Binding(
            get: { viewModel.amountText(for: field) },
            set: { viewModel.setAmountText($0, for: field) }
        )
    }

    func swapRows() {
        viewModel.swap()
        if focusedSlot != nil {
            focusedSlot = focusedSlot == .top ? .bottom : .top
        }
    }
}

#if DEBUG
#Preview {
    ConverterView(
        viewModel: DependencyContainer().makeConverterViewModel(),
        quoteCurrency: Currency(code: "XXX"),
        isPlaceholder: false,
        onSelectCurrency: {}
    )
}

#Preview("Placeholder") {
    ConverterView(
        viewModel: DependencyContainer().makeConverterViewModel(),
        quoteCurrency: Currency(code: "XXX"),
        isPlaceholder: true,
        onSelectCurrency: {}
    )
}
#endif
