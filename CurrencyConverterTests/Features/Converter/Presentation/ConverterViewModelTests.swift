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

    private func makeSUT(result: RatesLoadResult) -> ConverterViewModel {
        ConverterViewModel(
            convertUseCase: DefaultConvertCurrencyUseCase(),
            loadRatesUseCase: StubLoadExchangeRatesUseCase(result: result),
            quoteCurrency: mxn,
            locale: Locale(identifier: "en_US")
        )
    }

    @Test func activeRateValueUsesBidWhenBaseOnTop() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()

        #expect(sut.activeRateValue(for: mxn, isBaseOnTop: true) == 18.40)
    }

    @Test func activeRateValueUsesAskWhenBaseOnBottom() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()

        #expect(sut.activeRateValue(for: mxn, isBaseOnTop: false) == 18.42)
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
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()

        let text = sut.ratePillText(
            baseDisplayCode: "USDc",
            quoteDisplayCode: "MXN"
        )

        #expect(text == "1 USDc = 18.4000 MXN")
    }

    @Test func convertedAmountFromBaseMatchesUseCaseMath() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()

        let result = sut.convertedAmount(
            sourceText: "100",
            sourceField: .base,
            quoteCurrency: mxn,
            isBaseOnTop: true
        )

        #expect(result == "1,840.00")
    }

    @Test func convertedAmountFromQuoteMatchesUseCaseMath() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()

        let result = sut.convertedAmount(
            sourceText: "1842",
            sourceField: .quote,
            quoteCurrency: mxn,
            isBaseOnTop: false
        )

        #expect(result == "100.00")
    }

    @Test func convertedAmountKeepsEveryDigitBeyondEntryCap() async {
        let cop = Currency(code: "COP")
        let snapshot = ExchangeRatesSnapshot(
            rates: [ExchangeRate(quoteCurrencyCode: "COP", ask: 4000, bid: 4000)],
            fetchedAt: Date(timeIntervalSince1970: 0)
        )
        let sut = makeSUT(result: .loaded(snapshot, isFresh: true))
        await sut.loadRates()

        let result = sut.convertedAmount(
            sourceText: "999999999999",
            sourceField: .base,
            quoteCurrency: cop,
            isBaseOnTop: true
        )

        let parser = AmountInputSanitizer(locale: Locale(identifier: "en_US"))
        #expect(result.flatMap(parser.decimal(from:)) == Decimal(string: "3999999999996000"))
    }

    @Test func convertedAmountReturnsNilForUnparsableInput() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()

        let result = sut.convertedAmount(
            sourceText: "",
            sourceField: .base,
            quoteCurrency: mxn,
            isBaseOnTop: true
        )

        #expect(result == nil)
    }

    @Test func convertedAmountReturnsNilWhenNoRateForQuoteCurrency() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()

        let unknownQuoteCurrency = Currency(code: "ARS")
        let result = sut.convertedAmount(
            sourceText: "100",
            sourceField: .base,
            quoteCurrency: unknownQuoteCurrency,
            isBaseOnTop: true
        )

        #expect(result == nil)
    }

    @Test func typingBaseDerivesQuote() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()

        sut.setAmountText("100", for: .base)

        #expect(sut.quoteAmountText == "1,840.00")
    }

    @Test func swapRecalculatesDerivedAmountWithAskAndKeepsTypedAmount() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()
        sut.setAmountText("100", for: .base)

        sut.swap()

        #expect(sut.baseAmountText == "100")
        #expect(sut.quoteAmountText == "1,842.00")
    }

    @Test func swapAfterTypingQuoteRecalculatesBase() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
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
        let sut = makeSUT(result: .loaded(snapshot, isFresh: true))
        await sut.loadRates()
        sut.setAmountText("100", for: .base)

        sut.selectQuoteCurrency(Currency(code: "COP"))

        #expect(sut.quoteCurrency == Currency(code: "COP"))
        #expect(sut.quoteAmountText == "399,000.00")
    }

    @Test func loadingRatesRecalculatesDerivedAmount() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
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
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()

        #expect(sut.ratesAsOfText != nil)
    }
}

private struct StubLoadExchangeRatesUseCase: LoadExchangeRatesUseCase {
    let result: RatesLoadResult

    func load() async -> RatesLoadResult {
        result
    }
}
