import Foundation

/// Owns the converter screen's state and logic: loaded rates, both amounts, which row is on
/// top and the selected quote currency. Keyboard focus is the only state left on
/// `ConverterView`. Depends only on Domain protocols.
@Observable
final class ConverterViewModel {
    private(set) var ratesResult: RatesLoadResult = .unavailable
    /// Raw text of each amount field, keyed by currency rather than screen position.
    private(set) var baseAmountText = ""
    private(set) var quoteAmountText = ""
    /// Only `swap()` changes this. Drives row order and bid vs. ask - never keyboard focus.
    private(set) var isBaseOnTop = true
    private(set) var quoteCurrency: Currency
    /// The field the user last typed in - the source of truth. The other amount is always
    /// derived from it, including after a swap, a currency change or a rate refresh.
    private var lastEditedField: AmountField = .base

    private let convertUseCase: ConvertCurrencyUseCase
    private let loadRatesUseCase: LoadExchangeRatesUseCase
    private let sanitizer: AmountInputSanitizer
    private let displayFormatter: AmountDisplayFormatter
    private let locale: Locale

    init(
        convertUseCase: ConvertCurrencyUseCase,
        loadRatesUseCase: LoadExchangeRatesUseCase,
        quoteCurrency: Currency,
        locale: Locale = .current
    ) {
        self.quoteCurrency = quoteCurrency
        self.convertUseCase = convertUseCase
        self.loadRatesUseCase = loadRatesUseCase
        sanitizer = AmountInputSanitizer(locale: locale)
        displayFormatter = AmountDisplayFormatter(locale: locale)
        self.locale = locale
    }

    /// Fetches (or refreshes) rates for every catalog quote currency. Called on first
    /// appear and whenever the app returns to the foreground - never polled.
    func loadRates() async {
        ratesResult = await loadRatesUseCase.load()
        recalculateDerivedAmount()
    }

    // MARK: - Amounts

    func amountText(for field: AmountField) -> String {
        switch field {
        case .base: baseAmountText
        case .quote: quoteAmountText
        }
    }

    /// Called only for the user's own edits (the text field binding), never for derived
    /// values - so the field written here becomes the source the other one follows.
    func setAmountText(_ text: String, for field: AmountField) {
        guard text != amountText(for: field) else { return }
        switch field {
        case .base: baseAmountText = text
        case .quote: quoteAmountText = text
        }
        lastEditedField = field
        recalculateDerivedAmount()
    }

    /// Moves USDc to the other row. The typed amount stays put and the other one is
    /// recalculated, because the active rate flips between bid and ask.
    func swap() {
        isBaseOnTop.toggle()
        recalculateDerivedAmount()
    }

    func selectQuoteCurrency(_ currency: Currency) {
        guard currency != quoteCurrency else { return }
        quoteCurrency = currency
        recalculateDerivedAmount()
    }

    /// Rewrites the amount the user didn't type from the one they did, with the current
    /// rate, row order and quote currency. Clears it when there's nothing to convert.
    private func recalculateDerivedAmount() {
        switch lastEditedField {
        case .base:
            quoteAmountText = convertedAmount(
                sourceText: baseAmountText,
                sourceField: .base,
                quoteCurrency: quoteCurrency,
                isBaseOnTop: isBaseOnTop
            ) ?? ""
        case .quote:
            baseAmountText = convertedAmount(
                sourceText: quoteAmountText,
                sourceField: .quote,
                quoteCurrency: quoteCurrency,
                isBaseOnTop: isBaseOnTop
            ) ?? ""
        }
    }

    // MARK: - Rates

    /// Looks up `quoteCurrency`'s rate in the already-loaded snapshot. Switching the
    /// quote currency never triggers a re-fetch: the snapshot already holds every
    /// catalog currency's rate.
    func rate(for quoteCurrency: Currency) -> ExchangeRate? {
        guard case let .loaded(snapshot, _) = ratesResult else { return nil }
        return snapshot.rates.first { $0.quoteCurrencyCode == quoteCurrency.code }
    }

    /// Bid when the base currency is on top (selling USDc), ask when it's on the
    /// bottom (buying USDc) - driven purely by row position, never by focus.
    func activeRateValue(for quoteCurrency: Currency, isBaseOnTop: Bool) -> Decimal? {
        guard let rate = rate(for: quoteCurrency) else { return nil }
        return isBaseOnTop ? rate.bid : rate.ask
    }

    func ratePillText(baseDisplayCode: String, quoteDisplayCode: String) -> String {
        guard let value = activeRateValue(for: quoteCurrency, isBaseOnTop: isBaseOnTop) else {
            return String(localized: "Rate unavailable")
        }
        let formattedRate = displayFormatter.string(from: value, fractionDigits: 4)
        return "1 \(baseDisplayCode) = \(formattedRate) \(quoteDisplayCode)"
    }

    /// Client-capture time of the loaded snapshot, per the locked "rates as of" decision.
    /// `nil` when unavailable, so the caption simply doesn't render.
    var ratesAsOfText: String? {
        guard case let .loaded(snapshot, _) = ratesResult else { return nil }
        return snapshot.fetchedAt.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened).locale(locale)
        )
    }

    /// Converts `sourceText` (raw text from whichever field the user is typing in) to the
    /// other currency, formatted to 2 decimals. Returns `nil` when there's no rate to convert
    /// with or the text doesn't parse to a number - the caller clears the derived field in
    /// that case rather than showing a stale value.
    func convertedAmount(
        sourceText: String,
        sourceField: AmountField,
        quoteCurrency: Currency,
        isBaseOnTop: Bool
    ) -> String? {
        guard let rate = activeRateValue(for: quoteCurrency, isBaseOnTop: isBaseOnTop),
              let sourceAmount = sanitizer.decimal(from: sourceText)
        else {
            return nil
        }

        let result: Decimal = switch sourceField {
        case .base:
            convertUseCase.quoteAmount(fromBase: sourceAmount, rate: rate)
        case .quote:
            convertUseCase.baseAmount(fromQuote: sourceAmount, rate: rate)
        }
        return displayFormatter.string(from: result, fractionDigits: 2)
    }
}

