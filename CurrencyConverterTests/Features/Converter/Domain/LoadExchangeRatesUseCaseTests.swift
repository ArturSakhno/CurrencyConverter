import Foundation
import Testing
@testable import CurrencyConverter

struct LoadExchangeRatesUseCaseTests {
    private let sampleSnapshot = ExchangeRatesSnapshot(
        rates: [ExchangeRate(quoteCurrencyCode: "MXN", ask: 18.41, bid: 18.40)],
        fetchedAt: Date(timeIntervalSince1970: 0)
    )

    @Test func loadReturnsFreshSnapshotOnNetworkSuccess() async {
        let repository = StubExchangeRateRepository(fetchResult: .success(sampleSnapshot), cachedSnapshot: nil)
        let sut = DefaultLoadExchangeRatesUseCase(repository: repository, quoteCurrencyCodes: ["MXN"])

        let result = await sut.load()

        #expect(result == .loaded(sampleSnapshot, isFresh: true))
    }

    @Test func loadFallsBackToCacheOnNetworkFailure() async {
        let repository = StubExchangeRateRepository(fetchResult: .failure(.networkError), cachedSnapshot: sampleSnapshot)
        let sut = DefaultLoadExchangeRatesUseCase(repository: repository, quoteCurrencyCodes: ["MXN"])

        let result = await sut.load()

        #expect(result == .loaded(sampleSnapshot, isFresh: false))
    }

    @Test func loadReturnsUnavailableWhenNoNetworkAndNoCache() async {
        let repository = StubExchangeRateRepository(fetchResult: .failure(.networkError), cachedSnapshot: nil)
        let sut = DefaultLoadExchangeRatesUseCase(repository: repository, quoteCurrencyCodes: ["MXN"])

        let result = await sut.load()

        #expect(result == .unavailable)
    }
}

private struct StubExchangeRateRepository: ExchangeRateRepository {
    enum StubError: Error, Sendable { case networkError }

    let fetchResult: Result<ExchangeRatesSnapshot, StubError>
    let cachedSnapshot: ExchangeRatesSnapshot?

    func fetchLatestRates(for quoteCurrencyCodes: [String]) async throws -> ExchangeRatesSnapshot {
        try fetchResult.get()
    }

    func lastCachedSnapshot() -> ExchangeRatesSnapshot? {
        cachedSnapshot
    }
}
