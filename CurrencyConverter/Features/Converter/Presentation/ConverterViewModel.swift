import Foundation

nonisolated enum AmountField: Hashable {
    case base
    case quote
}

@Observable
final class ConverterViewModel {
    enum State: Equatable {
        case loading
        case failed(LoadError)
        case converter(Content)
    }

    enum LoadError: Error {
        case noConnection
        case unavailable
    }

    struct Content: Equatable {
        let availableCurrencies: [Currency]
        var quoteCurrency: Currency
        var snapshot: ExchangeRatesSnapshot
    }

    private enum FractionDigits {
        static let amount = 2
        static let rate = 4
    }

    let baseCurrency: Currency
    private(set) var state: State = .loading
    private(set) var baseAmountText = ""
    private(set) var quoteAmountText = ""
    private(set) var isBaseOnTop = true
    private(set) var isRetrying = false

    private let refreshInterval: Duration = .seconds(30)
    private let minimumRetryDuration: Duration = .seconds(1)

    private let convertUseCase: DefaultConvertCurrencyUseCase
    private let loadRatesUseCase: LoadExchangeRatesUseCase
    private let loadAvailableCurrenciesUseCase: CurrencyCatalogUseCase
    private let networkMonitor: NetworkMonitor
    private let amountFormatter: AmountFormatter
    private let locale: Locale

    private var lastEditedField: AmountField = .base

    init(
        convertUseCase: DefaultConvertCurrencyUseCase,
        loadRatesUseCase: LoadExchangeRatesUseCase,
        loadAvailableCurrenciesUseCase: CurrencyCatalogUseCase,
        networkMonitor: NetworkMonitor,
        baseCurrency: Currency,
        locale: Locale = .current
    ) {
        self.convertUseCase = convertUseCase
        self.loadRatesUseCase = loadRatesUseCase
        self.loadAvailableCurrenciesUseCase = loadAvailableCurrenciesUseCase
        self.networkMonitor = networkMonitor
        self.baseCurrency = baseCurrency
        self.locale = locale
        amountFormatter = AmountFormatter(locale: locale)
    }

    var ratesAsOfText: String? {
        content?.snapshot.fetchedAt.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened).locale(locale)
        )
    }

    private var content: Content? {
        guard case let .converter(content) = state else { return nil }
        return content
    }

    private var direction: TradeDirection {
        isBaseOnTop ? .sellingBase : .buyingBase
    }

    func keepRatesUpdated() async {
        while !Task.isCancelled {
            await refresh()
            try? await Task.sleep(for: refreshInterval)
        }
    }

    func refresh() async {
        guard let content else {
            await loadConverter()
            return
        }
        let snapshot = try? await loadRatesUseCase(rates: content.availableCurrencies.map(\.code))
        guard let snapshot, var current = self.content else { return }
        current.snapshot = snapshot
        state = .converter(current)
        recalculateDerivedAmount()
    }

    func onRetry() {
        Task { [weak self] in
            await self?.retry()
        }
    }

    func retry() async {
        guard !isRetrying else { return }
        isRetrying = true
        defer { isRetrying = false }

        let deadline = ContinuousClock.now + minimumRetryDuration
        await loadConverter()
        try? await Task.sleep(until: deadline, clock: .continuous)
    }

    func amountText(for field: AmountField) -> String {
        switch field {
        case .base: baseAmountText
        case .quote: quoteAmountText
        }
    }

    func setAmountText(_ text: String, for field: AmountField) {
        let current = amountText(for: field)
        let accepted = amountFormatter.sanitizeEdit(from: current, to: text)
        guard accepted != current else { return }
        switch field {
        case .base: baseAmountText = accepted
        case .quote: quoteAmountText = accepted
        }
        lastEditedField = field
        recalculateDerivedAmount()
    }

    func swap() {
        isBaseOnTop.toggle()
        recalculateDerivedAmount()
    }

    func selectQuoteCurrency(_ currency: Currency) {
        guard var content, currency != content.quoteCurrency else { return }
        content.quoteCurrency = currency
        state = .converter(content)
        recalculateDerivedAmount()
    }

    func ratePillText(baseDisplayCode: String, quoteDisplayCode: String) -> String {
        guard let content,
              let value = convertUseCase.price(of: content.quoteCurrency, direction: direction, in: content.snapshot)
        else {
            return String(localized: Localized.Converter.rateUnavailable)
        }
        let formattedRate = amountFormatter.string(from: value, fractionDigits: FractionDigits.rate)
        return String(localized: Localized.Converter.rateQuote(
            baseCode: baseDisplayCode,
            rate: formattedRate,
            quoteCode: quoteDisplayCode
        ))
    }
}

private extension ConverterViewModel {
    func convertedAmount(from text: String, side: CurrencySide) -> String? {
        guard let content,
              let amount = amountFormatter.decimal(from: text),
              let result = convertUseCase.convert(
                  amount,
                  from: side,
                  quote: content.quoteCurrency,
                  direction: direction,
                  in: content.snapshot
              )
        else {
            return nil
        }
        return amountFormatter.string(from: result, fractionDigits: FractionDigits.amount)
    }

    func recalculateDerivedAmount() {
        switch lastEditedField {
        case .base: quoteAmountText = convertedAmount(from: baseAmountText, side: .base) ?? ""
        case .quote: baseAmountText = convertedAmount(from: quoteAmountText, side: .quote) ?? ""
        }
    }

    func loadConverter() async {
        do {
            let loadedContent = try await loadContent()
            guard content == nil else { return }
            state = .converter(loadedContent)
            recalculateDerivedAmount()
        } catch {
            guard content == nil else { return }
            state = .failed(error)
        }
    }

    func loadContent() async throws(LoadError) -> Content {
        let currencies = await loadAvailableCurrenciesUseCase()
        guard let firstCurrency = currencies.first, let snapshot = try? await loadRatesUseCase(rates: currencies.map(\.code)) else {
            throw await networkMonitor.isConnected ? .unavailable : .noConnection
        }

        return Content(
            availableCurrencies: currencies,
            quoteCurrency: firstCurrency,
            snapshot: snapshot
        )
    }
}
