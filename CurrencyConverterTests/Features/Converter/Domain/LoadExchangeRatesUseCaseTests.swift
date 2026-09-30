@testable import CurrencyConverter
import Foundation
import Testing

struct LoadExchangeRatesUseCaseTests {
    private let sampleSnapshot = ExchangeRatesSnapshot(
        rates: [ExchangeRate(quoteCurrencyCode: "MXN", ask: 18.41, bid: 18.40)],
        fetchedAt: Date(timeIntervalSince1970: 0)
    )

    @Test func loadReturnsFreshSnapshotOnNetworkSuccess() async {
        let repository = StubExchangeRateRepository(fetchResult: .success(sampleSnapshot))
        let sut = DefaultLoadExchangeRatesUseCase(repository: repository, quoteCurrencyCodes: ["MXN"])

        let result = await sut.load()

        #expect(result == .loaded(sampleSnapshot))
    }

    @Test func loadReturnsUnavailableOnNetworkFailure() async {
        let repository = StubExchangeRateRepository(fetchResult: .failure(.networkError))
        let sut = DefaultLoadExchangeRatesUseCase(repository: repository, quoteCurrencyCodes: ["MXN"])

        let result = await sut.load()

        #expect(result == .unavailable)
    }
}

private struct StubExchangeRateRepository: ExchangeRateRepository {
    enum StubError: Error, Sendable { case networkError }

    let fetchResult: Result<ExchangeRatesSnapshot, StubError>

    func fetchLatestRates(for _: [String]) async throws -> ExchangeRatesSnapshot {
        try fetchResult.get()
    }
}
