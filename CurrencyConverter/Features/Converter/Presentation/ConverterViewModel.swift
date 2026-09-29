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
    /// The load in progress, so overlapping triggers (launch + foreground) share one request.
    private var loadTask: Task<Void, Never>?

    /// Rates are refreshed this long after the server issued them (`quotedAt`), and a failed
    /// load is retried after the same interval.
    static let refreshInterval: TimeInterval = 30
    /// Floor for the wait between refreshes, so a device clock ahead of the server's can't
    /// turn the loop into back-to-back requests.
    static let minimumRefreshDelay: TimeInterval = 1

    private let convertUseCase: ConvertCurrencyUseCase
    private let loadRatesUseCase: LoadExchangeRatesUseCase
    private let sanitizer: AmountInputSanitizer
    private let displayFormatter: AmountDisplayFormatter
    private let locale: Locale
    private let now: () -> Date
    private let sleep: @Sendable (TimeInterval) async throws -> Void

    init(
        convertUseCase: ConvertCurrencyUseCase,
        loadRatesUseCase: LoadExchangeRatesUseCase,
        quoteCurrency: Currency,
        locale: Locale = .current,
        now: @escaping () -> Date = Date.init,
        sleep: @escaping @Sendable (TimeInterval) async throws -> Void = { try await Task.sleep(for: .seconds($0)) }
    ) {
        self.quoteCurrency = quoteCurrency
        self.convertUseCase = convertUseCase
        self.loadRatesUseCase = loadRatesUseCase
        sanitizer = AmountInputSanitizer(locale: locale)
        displayFormatter = AmountDisplayFormatter(locale: locale)
        self.locale = locale
        self.now = now
        self.sleep = sleep
    }

    /// Loads rates now and then keeps them current: each refresh is scheduled
    /// `refreshInterval` after the server issued the quotes. Runs until the calling task is
    /// cancelled - `.task` does that when the screen goes away; in the background iOS
    /// suspends the app, and an overdue refresh fires as soon as it's back.
    func keepRatesUpdated() async {
        while !Task.isCancelled {
            await loadRates()
            do {
                try await sleep(delayUntilNextRefresh())
            } catch {
                return
            }
        }
    }

    /// Seconds until the rates on screen are due for a refresh, clamped to
    /// `minimumRefreshDelay...refreshInterval` so neither clock skew nor a future server
    /// time can make it tight-loop or stall. Stale or missing rates wait a full interval.
    func delayUntilNextRefresh() -> TimeInterval {
        guard case let .loaded(snapshot, isFresh: true) = ratesResult else { return Self.refreshInterval }
        let due = (snapshot.quotedAt ?? snapshot.fetchedAt).addingTimeInterval(Self.refreshInterval)
        return min(max(due.timeIntervalSince(now()), Self.minimumRefreshDelay), Self.refreshInterval)
    }

    /// Fetches rates for every catalog quote currency. If a load is already running, waits
    /// for it instead of starting a second request.
    func loadRates() async {
        if let loadTask {
            return await loadTask.value
        }
        let task = Task {
            let result = await loadRatesUseCase.load()
            ratesResult = merged(result, keeping: ratesResult)
            recalculateDerivedAmount()
        }
        loadTask = task
        await task.value
        loadTask = nil
    }

    /// For returns to the foreground: fetches only when the rates on screen aren't fresh or
    /// their refresh is already due, so quick app switching doesn't hit the API.
    func refreshIfStale() async {
        if case let .loaded(snapshot, isFresh: true) = ratesResult,
           now() < (snapshot.quotedAt ?? snapshot.fetchedAt).addingTimeInterval(Self.refreshInterval)
        {
            return
        }
        await loadRates()
    }

    /// A failed load never takes away rates already on screen - they stay, marked stale.
    private func merged(_ result: RatesLoadResult, keeping current: RatesLoadResult) -> RatesLoadResult {
        guard case .unavailable = result, case let .loaded(snapshot, _) = current else { return result }
        return .loaded(snapshot, isFresh: false)
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
}

private extension ConverterViewModel {
    /// Looks up `quoteCurrency`'s rate in the already-loaded snapshot. Switching the
    /// quote currency never triggers a re-fetch: the snapshot already holds every
    /// catalog currency's rate.
    func rate(for quoteCurrency: Currency) -> ExchangeRate? {
        guard case let .loaded(snapshot, _) = ratesResult else { return nil }
        return snapshot.rates.first { $0.quoteCurrencyCode == quoteCurrency.code }
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
