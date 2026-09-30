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

    /// How long to wait after a response, successful or not, before asking again.
    static let refreshInterval: Duration = .seconds(30)

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

    /// Loads rates now, then again `refreshInterval` after each response, until the calling
    /// task is cancelled (`.task` does that when the screen goes away). In the background iOS
    /// suspends the app; a wait that ran out meanwhile ends on return, so an overdue refresh
    /// happens right away.
    func keepRatesUpdated() async {
        while !Task.isCancelled {
            await loadRates()
            try? await Task.sleep(for: Self.refreshInterval)
        }
    }

    /// Fetches rates for every catalog quote currency.
    func loadRates() async {
        let result = await loadRatesUseCase.load()
        ratesResult = merged(result, keeping: ratesResult)
        recalculateDerivedAmount()
    }

    /// A failed load never takes away rates already on screen.
    private func merged(_ result: RatesLoadResult, keeping current: RatesLoadResult) -> RatesLoadResult {
        guard case .unavailable = result, case let .loaded(snapshot) = current else { return result }
        return .loaded(snapshot)
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
    /// The edit is sanitized first; one that sanitizes back to the current text (a third
    /// decimal, a digit past the entry cap) changes nothing, so the source stays put.
    func setAmountText(_ text: String, for field: AmountField) {
        let current = amountText(for: field)
        let accepted = sanitizer.sanitizeEdit(from: current, to: text)
        guard accepted != current else { return }
        switch field {
        case .base: baseAmountText = accepted
        case .quote: quoteAmountText = accepted
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
        case .base: quoteAmountText = convertedAmount(from: baseAmountText, side: .base) ?? ""
        case .quote: baseAmountText = convertedAmount(from: quoteAmountText, side: .quote) ?? ""
        }
    }

    func ratePillText(baseDisplayCode: String, quoteDisplayCode: String) -> String {
        guard let snapshot,
              let value = convertUseCase.price(of: quoteCurrency, direction: direction, in: snapshot)
        else {
            return String(localized: "Rate unavailable")
        }
        let formattedRate = displayFormatter.string(from: value, fractionDigits: 4)
        return "1 \(baseDisplayCode) = \(formattedRate) \(quoteDisplayCode)"
    }

    /// Client-capture time of the loaded snapshot, per the locked "rates as of" decision.
    /// `nil` when unavailable, so the caption simply doesn't render.
    var ratesAsOfText: String? {
        guard case let .loaded(snapshot) = ratesResult else { return nil }
        return snapshot.fetchedAt.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened).locale(locale)
        )
    }
}

private extension ConverterViewModel {
    /// The loaded rates. Switching the quote currency never re-fetches: the snapshot already
    /// holds every catalog currency's rate.
    var snapshot: ExchangeRatesSnapshot? {
        guard case let .loaded(snapshot) = ratesResult else { return nil }
        return snapshot
    }

    /// The top row is the one money leaves, so USDc on top means selling it. Driven purely
    /// by row position, never by focus.
    var direction: TradeDirection {
        isBaseOnTop ? .sellingBase : .buyingBase
    }

    /// Converts `text` (from whichever field the user is typing in) to the other currency,
    /// formatted to 2 decimals. `nil` when there's no rate or the text doesn't parse to a
    /// number - the caller clears the derived field rather than showing a stale value.
    func convertedAmount(from text: String, side: CurrencySide) -> String? {
        guard let snapshot,
              let amount = sanitizer.decimal(from: text),
              let result = convertUseCase.convert(
                  amount,
                  from: side,
                  quote: quoteCurrency,
                  direction: direction,
                  in: snapshot
              )
        else {
            return nil
        }
        return displayFormatter.string(from: result, fractionDigits: 2)
    }
}
