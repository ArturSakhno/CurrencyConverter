import DesignSystem
import SwiftUI

struct ConverterView: View {
    let viewModel: ConverterViewModel
    let quoteCurrency: Currency
    let isPlaceholder: Bool
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

    private static let placeholderAmount = "0.00"

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
                    Text(Localized.Converter.title)
                        .padding(.horizontal, DS.Spacing.m)
                        .textStyle(\.h3)
                        .foregroundStyle(.textPrimary)

                    Text(Localized.Converter.ratesAsOf(viewModel.ratesAsOfText ?? "00:00"))
                        .padding(.horizontal, DS.Spacing.m)
                        .textStyle(\.bodySmall)
                        .foregroundStyle(.textSecondary)
                        .skeleton(isPlaceholder)

                    ZStack {
                        VStack {
                            row(.top)
                                .containerShape(.rect)
                                .skeleton(isPlaceholder)
                                .padding(.bottom, Layout.rowGap)

                            row(.bottom)
                                .skeleton(isPlaceholder)
                                .padding(.top, Layout.rowGap)
                                .background(.bgPrimary)
                        }

                        exchange
                    }
                }
                .padding(.top, Layout.screenTop)
                .background(.bgSelected)

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

    private func row(_ slot: FocusSlot) -> some View {
        let isTop = slot == .top
        let isBase = isTop == viewModel.isBaseOnTop
        let currency = isPlaceholder || isBase ? viewModel.baseCurrency : quoteCurrency
        let info = CurrencyDisplayInfo.info(for: currency)
        return CurrencyInputField(
            amountText: isPlaceholder ? .constant(Self.placeholderAmount) : amountText(for: isBase ? .base : .quote),
            currencyCode: info.displayCode,
            sign: isPlaceholder ? nil : (isTop ? Sign.outgoing : Sign.incoming),
            currencySymbol: isPlaceholder ? nil : info.currencySymbol,
            subtitle: info.subtitle,
            showsChevron: !isPlaceholder && !isBase,
            imageName: info.flagAssetName,
            field: slot,
            focusedField: $focusedSlot,
            onSelectCurrency: isPlaceholder ? {} : onSelectCurrency
        )
        .padding(.horizontal, DS.Spacing.m)
        .padding(.vertical, DS.Spacing.l)
    }

    private var exchange: some View {
        ZStack(alignment: .leading) {
            SwapButton {
                viewModel.swap()
                if focusedSlot != nil {
                    focusedSlot = focusedSlot == .top ? .bottom : .top
                }
            }
            .rotationEffect(viewModel.isBaseOnTop ? .degrees(0) : .degrees(180))
            .animation(.default, value: viewModel.isBaseOnTop)
            .padding(.leading, DS.Spacing.m)

            ExchangeRateView(
                text: viewModel.ratePillText(
                    baseDisplayCode: CurrencyDisplayInfo.info(for: viewModel.baseCurrency).displayCode,
                    quoteDisplayCode: CurrencyDisplayInfo.info(for: quoteCurrency).displayCode
                )
            )
            .skeleton(isPlaceholder)
            .frame(maxWidth: .infinity)
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    ConverterView(
        viewModel: DependencyContainer().makeConverterViewModel(),
        quoteCurrency: Currency(code: "XXX"),
        isPlaceholder: true,
        onSelectCurrency: {}
    )
}
