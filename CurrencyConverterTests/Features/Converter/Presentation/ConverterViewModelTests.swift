@testable import CurrencyConverter
import Foundation
import Testing

@MainActor
struct ConverterViewModelTests {
    private let mxn = Currency(code: "MXN")
    private let cop = Currency(code: "COP")
    private let sampleSnapshot = ExchangeRatesSnapshot(
        rates: [ExchangeRate(quoteCurrencyCode: "MXN", ask: 18.42, bid: 18.40)],
        fetchedAt: Date(timeIntervalSince1970: 0)
    )

    @Test func ratePillTextFormatsRateToFourDecimals() async {
        let sut = makeSUT(result: .success(sampleSnapshot))
        await sut.refresh()

        let text = sut.ratePillText(baseDisplayCode: "USDc", quoteDisplayCode: "MXN")

        #expect(text == "1 USDc = 18.4000 MXN")
    }

    @Test func ratePillTextShowsUnavailableWhenTheSelectedCurrencyHasNoRate() async {
        let sut = makeSUT(result: .success(sampleSnapshot))
        await sut.refresh()
        sut.selectQuoteCurrency(cop)

        let text = sut.ratePillText(baseDisplayCode: "USDc", quoteDisplayCode: "COP")

        #expect(text == "Rate unavailable")
    }

    @Test func typingBaseDerivesQuote() async {
        let sut = makeSUT(result: .success(sampleSnapshot))
        await sut.refresh()

        sut.setAmountText("100", for: .base)

        #expect(sut.quoteAmountText == "1,840.00")
    }

    @Test func swapRecalculatesDerivedAmountWithAskAndKeepsTypedAmount() async {
        let sut = makeSUT(result: .success(sampleSnapshot))
        await sut.refresh()
        sut.setAmountText("100", for: .base)

        sut.swap()

        #expect(sut.baseAmountText == "100")
        #expect(sut.quoteAmountText == "1,842.00")
    }

    @Test func swapAfterTypingQuoteRecalculatesBase() async {
        let sut = makeSUT(result: .success(sampleSnapshot))
        await sut.refresh()
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
        let sut = makeSUT(result: .success(snapshot))
        await sut.refresh()
        sut.setAmountText("100", for: .base)

        sut.selectQuoteCurrency(cop)

        #expect(content(sut)?.quoteCurrency == cop)
        #expect(sut.quoteAmountText == "399,000.00")
    }

    @Test func typedAmountConvertsOnceRatesLoad() async {
        let sut = makeSUT(result: .success(sampleSnapshot))
        sut.setAmountText("100", for: .base)
        #expect(sut.quoteAmountText == "")

        await sut.refresh()

        #expect(sut.quoteAmountText == "1,840.00")
    }

    @Test func derivedAmountClearsWithoutRates() async {
        let sut = makeSUT(result: .failure(.unavailable))
        await sut.refresh()

        sut.setAmountText("100", for: .base)

        #expect(sut.quoteAmountText == "")
    }

    @Test func ratesAsOfTextIsNilWithoutRates() async {
        let sut = makeSUT(result: .failure(.unavailable))
        await sut.refresh()

        #expect(sut.ratesAsOfText == nil)
    }

    @Test func ratesAsOfTextReflectsFetchedAtWhenLoaded() async {
        let sut = makeSUT(result: .success(sampleSnapshot))
        await sut.refresh()

        #expect(sut.ratesAsOfText != nil)
    }
}

@MainActor
extension ConverterViewModelTests {
    @Test func startsLoading() {
        #expect(makeSUT(result: .success(sampleSnapshot)).state == .loading)
    }

    @Test func firstRefreshShowsTheConverterWithTheFirstCurrency() async {
        let sut = makeSUT(result: .success(sampleSnapshot))

        await sut.refresh()

        #expect(sut.state == .converter(.init(
            availableCurrencies: CurrencyCatalog.availableQuoteCurrencies,
            quoteCurrency: mxn,
            snapshot: sampleSnapshot
        )))
    }

    @Test func emptyCurrencyListShowsErrorScreen() async {
        let sut = makeSUT(results: [.success(sampleSnapshot)], loadedCurrencies: [])

        await sut.refresh()

        #expect(sut.state == .failed(.unavailable))
    }

    @Test func failedFirstRatesWhileOfflineShowNoConnection() async {
        let sut = makeSUT(results: [.failure(.unavailable)], networkMonitor: StubNetworkMonitor(isConnected: false))

        await sut.refresh()

        #expect(sut.state == .failed(.noConnection))
    }

    @Test func failedFirstRatesWhileOnlineShowUnavailable() async {
        let sut = makeSUT(results: [.failure(.unavailable)], networkMonitor: StubNetworkMonitor(isConnected: true))

        await sut.refresh()

        #expect(sut.state == .failed(.unavailable))
    }

    @Test func connectionComingBackRetriesAfterNoConnection() async {
        let sut = makeSUT(
            results: [.failure(.unavailable), .success(sampleSnapshot)],
            networkMonitor: StubNetworkMonitor(isConnected: false, updates: [false, true])
        )
        await sut.refresh()
        #expect(sut.state == .failed(.noConnection))

        await sut.retryWhenBackOnline()

        #expect(content(sut)?.snapshot == sampleSnapshot)
    }

    @Test func connectionUpdatesLeaveOtherFailuresToTheRefreshLoop() async {
        let sut = makeSUT(
            results: [.failure(.unavailable), .success(sampleSnapshot)],
            networkMonitor: StubNetworkMonitor(isConnected: true, updates: [true])
        )
        await sut.refresh()

        await sut.retryWhenBackOnline()

        #expect(sut.state == .failed(.unavailable))
    }

    @Test(arguments: [true, false])
    func currenciesCanRecoverAfterErrorScreen(usingRetry: Bool) async {
        let sut = ConverterViewModel(
            convertUseCase: DefaultConvertCurrencyUseCase(),
            loadRatesUseCase: StubLoadExchangeRatesUseCase(results: [.success(sampleSnapshot)]),
            loadAvailableCurrenciesUseCase: RecoveringCurrencyCatalogUseCase(currencies: [mxn]),
            networkMonitor: StubNetworkMonitor(),
            baseCurrency: CurrencyCatalog.base
        )
        await sut.refresh()
        #expect(sut.state == .failed(.unavailable))

        if usingRetry {
            await sut.retry()
        } else {
            await sut.refresh()
        }

        #expect(content(sut)?.quoteCurrency == mxn)
        #expect(content(sut)?.snapshot == sampleSnapshot)
    }

    @Test func retryAfterNoConnectionShowsTheConverter() async {
        let sut = makeSUT(
            results: [.failure(.unavailable), .success(sampleSnapshot)],
            networkMonitor: StubNetworkMonitor(isConnected: false)
        )
        await sut.refresh()

        await sut.retry()

        #expect(content(sut)?.snapshot == sampleSnapshot)
    }

    @Test func failedRefreshKeepsTheConverter() async {
        let sut = makeSUT(results: [.success(sampleSnapshot), .failure(.unavailable)])
        await sut.refresh()

        await sut.refresh()

        #expect(content(sut)?.snapshot == sampleSnapshot)
    }

    @Test func refreshKeepsTheSelectedCurrency() async {
        let sut = makeSUT(result: .success(sampleSnapshot))
        await sut.refresh()
        sut.selectQuoteCurrency(cop)

        await sut.refresh()

        #expect(content(sut)?.quoteCurrency == cop)
    }

    @Test func typedAmountIsSanitizedBeforeItIsStored() async {
        let sut = makeSUT(result: .success(sampleSnapshot))
        await sut.refresh()

        sut.setAmountText("1234.567", for: .base)

        #expect(sut.baseAmountText == "1,234.56")
        #expect(sut.quoteAmountText == "22,715.90")
    }

    @Test func rejectedEditInDerivedFieldKeepsTypedAmountAsSource() async {
        let sut = makeSUT(result: .success(sampleSnapshot))
        await sut.refresh()
        sut.setAmountText("100", for: .base)

        sut.setAmountText("1,840.005", for: .quote)

        #expect(sut.quoteAmountText == "1,840.00")
        #expect(sut.baseAmountText == "100")
        sut.swap()
        #expect(sut.baseAmountText == "100")
        #expect(sut.quoteAmountText == "1,842.00")
    }

    @Test func editsUseTheInjectedLocale() async {
        let sut = makeSUT(result: .success(sampleSnapshot), locale: Locale(identifier: "es_ES"))
        await sut.refresh()

        sut.setAmountText("12345,5", for: .base)

        #expect(sut.baseAmountText == "12.345,5")
        #expect(sut.quoteAmountText == "227.157,20")
    }
}

private extension ConverterViewModelTests {
    func makeSUT(
        results: [Result<ExchangeRatesSnapshot, ExchangeRatesError>],
        loadedCurrencies: [Currency] = CurrencyCatalog.availableQuoteCurrencies,
        networkMonitor: StubNetworkMonitor = StubNetworkMonitor(),
        locale: Locale = Locale(identifier: "en_US")
    ) -> ConverterViewModel {
        ConverterViewModel(
            convertUseCase: DefaultConvertCurrencyUseCase(),
            loadRatesUseCase: StubLoadExchangeRatesUseCase(results: results),
            loadAvailableCurrenciesUseCase: StubCurrencyCatalogUseCase(currencies: loadedCurrencies),
            networkMonitor: networkMonitor,
            baseCurrency: CurrencyCatalog.base,
            locale: locale
        )
    }

    func makeSUT(
        result: Result<ExchangeRatesSnapshot, ExchangeRatesError>,
        locale: Locale = Locale(identifier: "en_US")
    ) -> ConverterViewModel {
        makeSUT(results: [result], locale: locale)
    }

    func content(_ sut: ConverterViewModel) -> ConverterViewModel.Content? {
        guard case let .converter(content) = sut.state else { return nil }
        return content
    }
}

private actor StubLoadExchangeRatesUseCase: LoadExchangeRatesUseCase {
    private var results: [Result<ExchangeRatesSnapshot, ExchangeRatesError>]

    init(results: [Result<ExchangeRatesSnapshot, ExchangeRatesError>]) {
        self.results = results
    }

    func callAsFunction(rates _: [String]) async throws(ExchangeRatesError) -> ExchangeRatesSnapshot {
        let result = results.count > 1 ? results.removeFirst() : results[0]
        return try result.get()
    }
}

private struct StubCurrencyCatalogUseCase: CurrencyCatalogUseCase {
    let currencies: [Currency]

    func callAsFunction() async -> [Currency] {
        currencies
    }
}

private struct StubNetworkMonitor: NetworkMonitor {
    var isConnected = true
    var updates: [Bool] = []

    func connectivityUpdates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            for update in updates {
                continuation.yield(update)
            }
            continuation.finish()
        }
    }
}

private actor RecoveringCurrencyCatalogUseCase: CurrencyCatalogUseCase {
    private let currencies: [Currency]
    private var isFirstCall = true

    init(currencies: [Currency]) {
        self.currencies = currencies
    }

    func callAsFunction() async -> [Currency] {
        defer { isFirstCall = false }
        return isFirstCall ? [] : currencies
    }
}
