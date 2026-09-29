@testable import CurrencyConverter
import Foundation
import Testing

struct LoadExchangeRatesUseCaseTests {
    private let sampleSnapshot = ExchangeRatesSnapshot(
        rates: [ExchangeRate(quoteCurrency: Currency(code: "MXN"), ask: 18.41, bid: 18.40)],
        fetchedAt: Date(timeIntervalSince1970: 0)
    )

    private func makeSUT(repository: ExchangeRateRepository) -> DefaultLoadExchangeRatesUseCase {
        DefaultLoadExchangeRatesUseCase(
            repository: repository,
            baseCurrency: CurrencyCatalog.base,
            quoteCurrencies: [Currency(code: "MXN")]
        )
    }

    @Test func loadReturnsFreshSnapshotOnNetworkSuccess() async {
        let repository = StubExchangeRateRepository(fetchResult: .success(sampleSnapshot), cachedSnapshot: nil)
        let sut = makeSUT(repository: repository)

        let result = await sut.load()

        #expect(result == .loaded(sampleSnapshot, isFresh: true))
    }

    @Test func loadFallsBackToCacheOnNetworkFailure() async {
        let repository = StubExchangeRateRepository(fetchResult: .failure(.networkError), cachedSnapshot: sampleSnapshot)
        let sut = makeSUT(repository: repository)

        let result = await sut.load()

        #expect(result == .loaded(sampleSnapshot, isFresh: false))
    }

    @Test func loadReturnsUnavailableWhenNoNetworkAndNoCache() async {
        let repository = StubExchangeRateRepository(fetchResult: .failure(.networkError), cachedSnapshot: nil)
        let sut = makeSUT(repository: repository)

        let result = await sut.load()

        #expect(result == .unavailable)
    }
}

private struct StubExchangeRateRepository: ExchangeRateRepository {
    enum StubError: Error, Sendable { case networkError }

    let fetchResult: Result<ExchangeRatesSnapshot, StubError>
    let cachedSnapshot: ExchangeRatesSnapshot?

    func fetchLatestRates(base _: Currency, quotes _: [Currency]) async throws -> ExchangeRatesSnapshot {
        try fetchResult.get()
    }

    func lastCachedSnapshot() -> ExchangeRatesSnapshot? {
        cachedSnapshot
    }
}
