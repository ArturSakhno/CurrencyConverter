@testable import CurrencyConverter
import Foundation
import Testing

@MainActor
struct ConverterViewModelTests {
    private let mxn = Currency(code: "MXN")
    private let sampleSnapshot = ExchangeRatesSnapshot(
        rates: [ExchangeRate(quoteCurrencyCode: "MXN", ask: 18.42, bid: 18.40)],
        fetchedAt: Date(timeIntervalSince1970: 0)
    )

    private func makeSUT(
        results: [RatesLoadResult],
        locale: Locale = Locale(identifier: "en_US")
    ) -> ConverterViewModel {
        ConverterViewModel(
            convertUseCase: DefaultConvertCurrencyUseCase(),
            loadRatesUseCase: StubLoadExchangeRatesUseCase(results: results),
            quoteCurrency: mxn,
            locale: locale
        )
    }

    private func makeSUT(
        result: RatesLoadResult,
        locale: Locale = Locale(identifier: "en_US")
    ) -> ConverterViewModel {
        makeSUT(results: [result], locale: locale)
    }

    @Test func ratePillTextShowsUnavailableStringWhenUnavailable() async {
        let sut = makeSUT(result: .unavailable)
        await sut.loadRates()

        let text = sut.ratePillText(
            baseDisplayCode: "USDc",
            quoteDisplayCode: "MXN"
        )

        #expect(text == "Rate unavailable")
    }

    @Test func ratePillTextFormatsRateToFourDecimals() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot))
        await sut.loadRates()

        let text = sut.ratePillText(
            baseDisplayCode: "USDc",
            quoteDisplayCode: "MXN"
        )

        #expect(text == "1 USDc = 18.4000 MXN")
    }

    @Test func typingBaseDerivesQuote() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot))
        await sut.loadRates()

        sut.setAmountText("100", for: .base)

        #expect(sut.quoteAmountText == "1,840.00")
    }

    @Test func swapRecalculatesDerivedAmountWithAskAndKeepsTypedAmount() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot))
        await sut.loadRates()
        sut.setAmountText("100", for: .base)

        sut.swap()

        #expect(sut.baseAmountText == "100")
        #expect(sut.quoteAmountText == "1,842.00")
    }

    @Test func swapAfterTypingQuoteRecalculatesBase() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot))
        await sut.loadRates()
        sut.swap()
        sut.setAmountText("1,842", for: .quote)
        #expect(sut.baseAmountText == "100.00")

        sut.swap()

        #expect(sut.quoteAmountText == "1,842")
        #expect(sut.baseAmountText == "100.11")
    }

    @Test func selectingQuoteCurrencyRecalculatesDerivedAmount() async {
        let snapshot = ExchangeRatesSnapshot(
            rates: [
                ExchangeRate(quoteCurrencyCode: "MXN", ask: 18.42, bid: 18.40),
                ExchangeRate(quoteCurrencyCode: "COP", ask: 4000, bid: 3990),
            ],
            fetchedAt: Date(timeIntervalSince1970: 0)
        )
        let sut = makeSUT(result: .loaded(snapshot))
        await sut.loadRates()
        sut.setAmountText("100", for: .base)

        sut.selectQuoteCurrency(Currency(code: "COP"))

        #expect(sut.quoteCurrency == Currency(code: "COP"))
        #expect(sut.quoteAmountText == "399,000.00")
    }

    @Test func loadingRatesRecalculatesDerivedAmount() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot))
        sut.setAmountText("100", for: .base)
        #expect(sut.quoteAmountText == "")

        await sut.loadRates()

        #expect(sut.quoteAmountText == "1,840.00")
    }

    @Test func derivedAmountClearsWhenRateIsMissing() async {
        let sut = makeSUT(result: .unavailable)
        await sut.loadRates()

        sut.setAmountText("100", for: .base)

        #expect(sut.quoteAmountText == "")
    }

    @Test func ratesAsOfTextIsNilWhenUnavailable() async {
        let sut = makeSUT(result: .unavailable)
        await sut.loadRates()

        #expect(sut.ratesAsOfText == nil)
    }

    @Test func ratesAsOfTextReflectsFetchedAtWhenLoaded() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot))
        await sut.loadRates()

        #expect(sut.ratesAsOfText != nil)
    }

    @Test func failedReloadKeepsRatesOnScreenMarkedStale() async {
        let sut = makeSUT(results: [.loaded(sampleSnapshot), .unavailable])
        await sut.loadRates()

        await sut.loadRates()

        #expect(sut.ratesResult == .loaded(sampleSnapshot))
    }
}

@MainActor
extension ConverterViewModelTests {
    @Test func typedAmountIsSanitizedBeforeItIsStored() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot))
        await sut.loadRates()

        sut.setAmountText("1234.567", for: .base)

        #expect(sut.baseAmountText == "1,234.56")
        #expect(sut.quoteAmountText == "22,715.90")
    }

    @Test func rejectedEditInDerivedFieldKeepsTypedAmountAsSource() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot))
        await sut.loadRates()
        sut.setAmountText("100", for: .base)

        sut.setAmountText("1,840.005", for: .quote)

        #expect(sut.quoteAmountText == "1,840.00")
        #expect(sut.baseAmountText == "100")
        sut.swap()
        #expect(sut.baseAmountText == "100")
        #expect(sut.quoteAmountText == "1,842.00")
    }

    @Test func editsUseTheInjectedLocale() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot), locale: Locale(identifier: "es_ES"))
        await sut.loadRates()

        sut.setAmountText("12345,5", for: .base)

        #expect(sut.baseAmountText == "12.345,5")
        #expect(sut.quoteAmountText == "227.157,20")
    }
}

private actor StubLoadExchangeRatesUseCase: LoadExchangeRatesUseCase {
    private var results: [RatesLoadResult]

    init(results: [RatesLoadResult]) {
        self.results = results
    }

    func load() async -> RatesLoadResult {
        results.count > 1 ? results.removeFirst() : results[0]
    }
}
