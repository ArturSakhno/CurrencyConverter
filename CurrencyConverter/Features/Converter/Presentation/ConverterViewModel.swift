import Foundation

@Observable
final class ConverterViewModel {
    private(set) var ratesResult: RatesLoadResult = .unavailable
    private(set) var baseAmountText = ""
    private(set) var quoteAmountText = ""
    private(set) var isBaseOnTop = true
    private(set) var quoteCurrency: Currency
    private var lastEditedField: AmountField = .base

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

    func keepRatesUpdated() async {
        while !Task.isCancelled {
            await loadRates()
            try? await Task.sleep(for: Self.refreshInterval)
        }
    }

    func loadRates() async {
        let result = await loadRatesUseCase.load()
        ratesResult = merged(result, keeping: ratesResult)
        recalculateDerivedAmount()
    }

    private func merged(_ result: RatesLoadResult, keeping current: RatesLoadResult) -> RatesLoadResult {
        guard case .unavailable = result, case let .loaded(snapshot) = current else { return result }
        return .loaded(snapshot)
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
        guard currency != quoteCurrency else { return }
        quoteCurrency = currency
        recalculateDerivedAmount()
    }

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

    var ratesAsOfText: String? {
        guard case let .loaded(snapshot) = ratesResult else { return nil }
        return snapshot.fetchedAt.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened).locale(locale)
        )
    }
}

private extension ConverterViewModel {
    var snapshot: ExchangeRatesSnapshot? {
        guard case let .loaded(snapshot) = ratesResult else { return nil }
        return snapshot
    }

    var direction: TradeDirection {
        isBaseOnTop ? .sellingBase : .buyingBase
    }

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
