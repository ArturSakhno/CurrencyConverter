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
        result: RatesLoadResult,
        locale: Locale = Locale(identifier: "en_US")
    ) -> ConverterViewModel {
        ConverterViewModel(
            convertUseCase: DefaultConvertCurrencyUseCase(),
            loadRatesUseCase: StubLoadExchangeRatesUseCase(result: result),
            quoteCurrency: mxn,
            locale: locale
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

    // MARK: - Refresh throttle

    private func makeCountingSUT(
        results: [RatesLoadResult],
        now: @escaping () -> Date = { Date(timeIntervalSince1970: 10) }
    ) -> (ConverterViewModel, CountingLoadExchangeRatesUseCase) {
        let useCase = CountingLoadExchangeRatesUseCase(results: results)
        let sut = ConverterViewModel(
            convertUseCase: DefaultConvertCurrencyUseCase(),
            loadRatesUseCase: useCase,
            quoteCurrency: mxn,
            locale: Locale(identifier: "en_US"),
            now: now
        )
        return (sut, useCase)
    }

    @Test func refreshIfStaleSkipsWithinMinimumInterval() async {
        // sampleSnapshot was fetched at t=0; "now" is 10 s later.
        let (sut, useCase) = makeCountingSUT(results: [.loaded(sampleSnapshot, isFresh: true)])
        await sut.loadRates()

        await sut.refreshIfStale()

        #expect(await useCase.callCount == 1)
    }

    @Test func refreshIfStaleFetchesAfterMinimumInterval() async {
        let (sut, useCase) = makeCountingSUT(
            results: [.loaded(sampleSnapshot, isFresh: true)],
            now: { Date(timeIntervalSince1970: ConverterViewModel.refreshInterval + 1) }
        )
        await sut.loadRates()

        await sut.refreshIfStale()

        #expect(await useCase.callCount == 2)
    }

    @Test func refreshIfStaleAlwaysRetriesStaleRates() async {
        let (sut, useCase) = makeCountingSUT(results: [.loaded(sampleSnapshot, isFresh: false)])
        await sut.loadRates()

        await sut.refreshIfStale()

        #expect(await useCase.callCount == 2)
    }

    @Test func refreshIfStaleFetchesWhenNothingIsLoaded() async {
        let (sut, useCase) = makeCountingSUT(results: [.unavailable])

        await sut.refreshIfStale()

        #expect(await useCase.callCount == 1)
    }

    @Test func overlappingLoadsShareOneRequest() async {
        let (sut, useCase) = makeCountingSUT(results: [.loaded(sampleSnapshot, isFresh: true)])

        async let first: Void = sut.loadRates()
        async let second: Void = sut.loadRates()
        _ = await (first, second)

        #expect(await useCase.callCount == 1)
        #expect(sut.ratesResult == .loaded(sampleSnapshot, isFresh: true))
    }

    @Test func failedReloadKeepsRatesOnScreenMarkedStale() async {
        let (sut, _) = makeCountingSUT(results: [.loaded(sampleSnapshot, isFresh: true), .unavailable])
        await sut.loadRates()

        await sut.loadRates()

        #expect(sut.ratesResult == .loaded(sampleSnapshot, isFresh: false))
    }

    // MARK: - Refresh schedule

    private func snapshot(fetchedAt: TimeInterval, quotedAt: TimeInterval?) -> ExchangeRatesSnapshot {
        ExchangeRatesSnapshot(
            rates: [ExchangeRate(
                quoteCurrencyCode: "MXN",
                ask: 18.42,
                bid: 18.40,
                quotedAt: quotedAt.map(Date.init(timeIntervalSince1970:))
            )],
            fetchedAt: Date(timeIntervalSince1970: fetchedAt)
        )
    }

    @Test func nextRefreshIsDueThirtySecondsAfterQuoteTime() async {
        // Quoted at t=95, fetched at t=100 (device clock ahead), now t=110 -> due at 125.
        let (sut, _) = makeCountingSUT(
            results: [.loaded(snapshot(fetchedAt: 100, quotedAt: 95), isFresh: true)],
            now: { Date(timeIntervalSince1970: 110) }
        )
        await sut.loadRates()

        #expect(sut.delayUntilNextRefresh() == 15)
    }

    @Test func nextRefreshFallsBackToFetchTimeWithoutQuoteTime() async {
        let (sut, _) = makeCountingSUT(
            results: [.loaded(snapshot(fetchedAt: 100, quotedAt: nil), isFresh: true)],
            now: { Date(timeIntervalSince1970: 110) }
        )
        await sut.loadRates()

        #expect(sut.delayUntilNextRefresh() == 20)
    }

    @Test func nextRefreshDelayIsClampedAgainstClockSkew() async {
        let overdue = makeCountingSUT(
            results: [.loaded(snapshot(fetchedAt: 0, quotedAt: 0), isFresh: true)],
            now: { Date(timeIntervalSince1970: 500) }
        ).0
        let fromTheFuture = makeCountingSUT(
            results: [.loaded(snapshot(fetchedAt: 0, quotedAt: 3600), isFresh: true)],
            now: { Date(timeIntervalSince1970: 0) }
        ).0
        await overdue.loadRates()
        await fromTheFuture.loadRates()

        #expect(overdue.delayUntilNextRefresh() == ConverterViewModel.minimumRefreshDelay)
        #expect(fromTheFuture.delayUntilNextRefresh() == ConverterViewModel.refreshInterval)
    }

    @Test func staleRatesRetryAfterAFullInterval() async {
        let (sut, _) = makeCountingSUT(results: [.unavailable])
        await sut.loadRates()

        #expect(sut.delayUntilNextRefresh() == ConverterViewModel.refreshInterval)
    }

    @Test func keepRatesUpdatedReloadsAfterEachScheduledDelay() async {
        let recorder = SleepRecorder(stopAfter: 3)
        let useCase = CountingLoadExchangeRatesUseCase(
            results: [.loaded(snapshot(fetchedAt: 100, quotedAt: 95), isFresh: true)]
        )
        let sut = ConverterViewModel(
            convertUseCase: DefaultConvertCurrencyUseCase(),
            loadRatesUseCase: useCase,
            quoteCurrency: mxn,
            locale: Locale(identifier: "en_US"),
            now: { Date(timeIntervalSince1970: 110) },
            sleep: { try await recorder.sleep($0) }
        )

        await sut.keepRatesUpdated()

        #expect(await useCase.callCount == 3)
        #expect(await recorder.delays == [15, 15, 15])
    }
}

// MARK: - Edits

@MainActor
extension ConverterViewModelTests {
    @Test func typedAmountIsSanitizedBeforeItIsStored() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()

        sut.setAmountText("1234.567", for: .base)

        #expect(sut.baseAmountText == "1,234.56")
        #expect(sut.quoteAmountText == "22,715.90")
    }

    @Test func rejectedEditInDerivedFieldKeepsTypedAmountAsSource() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true))
        await sut.loadRates()
        sut.setAmountText("100", for: .base)

        // A third decimal sanitizes back to the current text, so the edit is rejected.
        sut.setAmountText("1,840.005", for: .quote)

        #expect(sut.quoteAmountText == "1,840.00")
        #expect(sut.baseAmountText == "100")
        // USDc is still the source: a swap keeps it and re-derives the quote with the ask.
        sut.swap()
        #expect(sut.baseAmountText == "100")
        #expect(sut.quoteAmountText == "1,842.00")
    }

    @Test func editsUseTheInjectedLocale() async {
        let sut = makeSUT(result: .loaded(sampleSnapshot, isFresh: true), locale: Locale(identifier: "es_ES"))
        await sut.loadRates()

        sut.setAmountText("12345,5", for: .base)

        #expect(sut.baseAmountText == "12.345,5")
        #expect(sut.quoteAmountText == "227.157,20")
    }
}

/// Stands in for `Task.sleep`: records each requested delay and returns immediately, then
/// throws `CancellationError` on the `stopAfter`-th call so the refresh loop ends.
private actor SleepRecorder {
    private let stopAfter: Int
    private(set) var delays: [TimeInterval] = []

    init(stopAfter: Int) {
        self.stopAfter = stopAfter
    }

    func sleep(_ delay: TimeInterval) throws {
        delays.append(delay)
        if delays.count >= stopAfter {
            throw CancellationError()
        }
    }
}

/// Returns `results` in order (repeating the last one) and counts calls. Sleeps briefly so
/// overlapping `loadRates()` calls really are in flight at the same time.
private actor CountingLoadExchangeRatesUseCase: LoadExchangeRatesUseCase {
    private let results: [RatesLoadResult]
    private(set) var callCount = 0

    init(results: [RatesLoadResult]) {
        self.results = results
    }

    func load() async -> RatesLoadResult {
        callCount += 1
        let result = results[min(callCount, results.count) - 1]
        try? await Task.sleep(for: .milliseconds(20))
        return result
    }
}

private struct StubLoadExchangeRatesUseCase: LoadExchangeRatesUseCase {
    let result: RatesLoadResult

    func load() async -> RatesLoadResult {
        result
    }
}
