import Foundation

/// Owns rate loading and conversion math for the converter screen. UI-only state (which
/// currency is on top, keyboard focus, the raw text in each field) intentionally stays on
/// `ConverterView` itself - this type only knows about Domain protocols and business logic.
@Observable
final class ConverterViewModel {
    private(set) var ratesResult: RatesLoadResult = .unavailable

    private let convertUseCase: ConvertCurrencyUseCase
    private let loadRatesUseCase: LoadExchangeRatesUseCase
    private let sanitizer: AmountInputSanitizer
    private let displayFormatter: AmountDisplayFormatter
    private let locale: Locale

    init(
        convertUseCase: ConvertCurrencyUseCase,
        loadRatesUseCase: LoadExchangeRatesUseCase,
        locale: Locale = .current
    ) {
        self.convertUseCase = convertUseCase
        self.loadRatesUseCase = loadRatesUseCase
        self.sanitizer = AmountInputSanitizer(locale: locale)
        self.displayFormatter = AmountDisplayFormatter(locale: locale)
        self.locale = locale
    }

    /// Fetches (or refreshes) rates for every catalog quote currency. Called on first
    /// appear and whenever the app returns to the foreground - never polled.
    func loadRates() async {
        ratesResult = await loadRatesUseCase.load()
    }

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

    func ratePillText(
        quoteCurrency: Currency,
        isBaseOnTop: Bool,
        baseDisplayCode: String,
        quoteDisplayCode: String
    ) -> String {
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
              let sourceAmount = sanitizer.decimal(from: sourceText) else {
            return nil
        }

        let result: Decimal
        switch sourceField {
        case .base:
            result = convertUseCase.quoteAmount(fromBase: sourceAmount, rate: rate)
        case .quote:
            result = convertUseCase.baseAmount(fromQuote: sourceAmount, rate: rate)
        }
        return displayFormatter.string(from: result, fractionDigits: 2)
    }
}
