@testable import CurrencyConverter
import Foundation
import Testing

@MainActor
struct ConverterViewModelOverlappingLoadTests {
    private let cop = Currency(code: "COP")
    private let retrySnapshot: ExchangeRatesSnapshot
    private let lateSnapshot: ExchangeRatesSnapshot

    init() throws {
        let mxnRate = try ExchangeRate(
            quoteCurrencyCode: "MXN",
            ask: #require(Decimal(string: "18.42")),
            bid: #require(Decimal(string: "18.40"))
        )
        retrySnapshot = ExchangeRatesSnapshot(rates: [mxnRate], fetchedAt: Date(timeIntervalSince1970: 0))
        lateSnapshot = ExchangeRatesSnapshot(rates: [mxnRate], fetchedAt: Date(timeIntervalSince1970: 1))
    }

    @Test(arguments: [false, true])
    func lateFirstLoadKeepsTheConverterShownByRetry(lateLoadSucceeds: Bool) async {
        let loadRatesUseCase = HeldFirstLoadExchangeRatesUseCase(laterSnapshot: retrySnapshot)
        let sut = ConverterViewModel(
            convertUseCase: DefaultConvertCurrencyUseCase(),
            loadRatesUseCase: loadRatesUseCase,
            loadAvailableCurrenciesUseCase: DefaultCurrencyCatalogUseCase(repository: FallbackCurrencyCatalogRepository()),
            networkMonitor: OnlineNetworkMonitor(),
            baseCurrency: CurrencyCatalog.base
        )
        let firstLoad = Task { await sut.refresh() }
        await loadRatesUseCase.waitForFirstCall()

        await sut.retry()
        sut.selectQuoteCurrency(cop)
        await loadRatesUseCase.finishFirstCall(with: lateLoadSucceeds ? .success(lateSnapshot) : .failure(.unavailable))
        await firstLoad.value

        guard case let .converter(content) = sut.state else {
            Issue.record("Expected the converter, got \(sut.state)")
            return
        }
        #expect(content.quoteCurrency == cop)
        #expect(content.snapshot == retrySnapshot)
    }
}

private actor HeldFirstLoadExchangeRatesUseCase: LoadExchangeRatesUseCase {
    private let laterSnapshot: ExchangeRatesSnapshot
    private let firstCallStarted: AsyncStream<Void>
    private let firstCallStartedContinuation: AsyncStream<Void>.Continuation
    private var heldCall: CheckedContinuation<Result<ExchangeRatesSnapshot, ExchangeRatesError>, Never>?
    private var callCount = 0

    init(laterSnapshot: ExchangeRatesSnapshot) {
        self.laterSnapshot = laterSnapshot
        (firstCallStarted, firstCallStartedContinuation) = AsyncStream.makeStream()
    }

    func callAsFunction(rates _: [String]) async throws(ExchangeRatesError) -> ExchangeRatesSnapshot {
        callCount += 1
        guard callCount == 1 else { return laterSnapshot }
        return try await withCheckedContinuation { continuation in
            heldCall = continuation
            firstCallStartedContinuation.yield()
        }.get()
    }

    func waitForFirstCall() async {
        for await _ in firstCallStarted {
            return
        }
    }

    func finishFirstCall(with result: Result<ExchangeRatesSnapshot, ExchangeRatesError>) {
        heldCall?.resume(returning: result)
        heldCall = nil
    }
}

private struct OnlineNetworkMonitor: NetworkMonitor {
    var isConnected: Bool { true }

    func connectivityUpdates() -> AsyncStream<Bool> {
        AsyncStream { $0.finish() }
    }
}
