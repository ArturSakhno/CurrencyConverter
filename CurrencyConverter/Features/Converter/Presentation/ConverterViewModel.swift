import Foundation

@Observable
final class ConverterViewModel {
    enum State: Equatable {
        case loading
        case noConnection
        case errorScreen
        case converter(Content)
    }

    struct Content: Equatable {
        var quoteCurrency: Currency
        let availableCurrencies: [Currency]
        var snapshot: ExchangeRatesSnapshot
    }

    let baseCurrency: Currency
    private(set) var state: State = .loading
    private(set) var baseAmountText = ""
    private(set) var quoteAmountText = ""
    private(set) var isBaseOnTop = true
    private var lastEditedField: AmountField = .base

    static let refreshInterval: Duration = .seconds(30)

    private let convertUseCase: ConvertCurrencyUseCase
    private let loadRatesUseCase: LoadExchangeRatesUseCase
    private let loadAvailableCurrenciesUseCase: CurrencyCatalogUseCase
    private let sanitizer: AmountInputSanitizer
    private let displayFormatter: AmountDisplayFormatter
    private let locale: Locale

    init(
        convertUseCase: ConvertCurrencyUseCase,
        loadRatesUseCase: LoadExchangeRatesUseCase,
        loadAvailableCurrenciesUseCase: CurrencyCatalogUseCase,
        baseCurrency: Currency,
        locale: Locale = .current
    ) {
        self.convertUseCase = convertUseCase
        self.loadRatesUseCase = loadRatesUseCase
        self.loadAvailableCurrenciesUseCase = loadAvailableCurrenciesUseCase
        self.baseCurrency = baseCurrency
        self.locale = locale
        sanitizer = AmountInputSanitizer(locale: locale)
        displayFormatter = AmountDisplayFormatter(locale: locale)
    }

    func keepRatesUpdated() async {
        while !Task.isCancelled {
            await refresh()
            try? await Task.sleep(for: Self.refreshInterval)
        }
    }

    func refresh() async {
        guard let content else {
            await loadConverter()
            return
        }
        let result = await loadRatesUseCase(rates: content.availableCurrencies.map(\.code))
        guard case let .loaded(snapshot) = result, var current = self.content else { return }
        current.snapshot = snapshot
        state = .converter(current)
        recalculateDerivedAmount()
    }

    func retry() async {
        state = .loading
        await loadConverter()
    }

    private func loadConverter() async {
        let currencies = await loadAvailableCurrenciesUseCase()
        guard let firstCurrency = currencies.first else {
            state = .errorScreen
            return
        }
        guard case let .loaded(snapshot) = await loadRatesUseCase(rates: currencies.map(\.code)) else {
            state = .noConnection
            return
        }
        state = .converter(Content(
            quoteCurrency: firstCurrency,
            availableCurrencies: currencies,
            snapshot: snapshot
        ))
        recalculateDerivedAmount()
    }

    func amountText(for field: AmountField) -> String {
        switch field {
        case .base: baseAmountText
        case .quote: quoteAmountText
        }
    }

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

    private func recalculateDerivedAmount() {
        switch lastEditedField {
        case .base: quoteAmountText = convertedAmount(from: baseAmountText, side: .base) ?? ""
        case .quote: baseAmountText = convertedAmount(from: quoteAmountText, side: .quote) ?? ""
        }
    }

    func ratePillText(baseDisplayCode: String, quoteDisplayCode: String) -> String {
        guard let content,
              let value = convertUseCase.price(of: content.quoteCurrency, direction: direction, in: content.snapshot)
        else {
            return String(localized: "Rate unavailable")
        }
        let formattedRate = displayFormatter.string(from: value, fractionDigits: 4)
        return "1 \(baseDisplayCode) = \(formattedRate) \(quoteDisplayCode)"
    }

    var ratesAsOfText: String? {
        content?.snapshot.fetchedAt.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened).locale(locale)
        )
    }
}

private extension ConverterViewModel {
    var content: Content? {
        guard case let .converter(content) = state else { return nil }
        return content
    }

    var direction: TradeDirection {
        isBaseOnTop ? .sellingBase : .buyingBase
    }

    func convertedAmount(from text: String, side: CurrencySide) -> String? {
        guard let content,
              let amount = sanitizer.decimal(from: text),
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
        return displayFormatter.string(from: result, fractionDigits: 2)
    }
}
