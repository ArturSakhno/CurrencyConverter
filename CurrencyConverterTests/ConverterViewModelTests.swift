import Foundation
import Testing
@testable import CurrencyConverter

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
            quoteCurrency: mxn,
            isBaseOnTop: true,
            baseDisplayCode: "USDc",
            quoteDisplayCode: "MXN"
        )

        #expect(text == "Rate unavailable")
    }

    @Test func ratePillTextFormatsRateToFourDecimals() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()

        let text = sut.ratePillText(
            quoteCurrency: mxn,
            isBaseOnTop: true,
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

        #expect(result == "1840.00")
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
