@testable import CurrencyConverter
import Foundation
import Testing

struct LoadExchangeRatesUseCaseTests {
    private let sampleSnapshot = ExchangeRatesSnapshot(
        rates: [ExchangeRate(quoteCurrencyCode: "MXN", ask: 18.41, bid: 18.40)],
        fetchedAt: Date(timeIntervalSince1970: 0)
    )

    @Test func loadReturnsFreshSnapshotOnNetworkSuccess() async throws {
        let repository = StubExchangeRateRepository(fetchResult: .success(sampleSnapshot))
        let sut = DefaultLoadExchangeRatesUseCase(repository: repository)

        let snapshot = try await sut(rates: ["MXN"])

        #expect(snapshot == sampleSnapshot)
    }

    @Test func loadThrowsUnavailableOnNetworkFailure() async {
        let repository = StubExchangeRateRepository(fetchResult: .failure(.unavailable))
        let sut = DefaultLoadExchangeRatesUseCase(repository: repository)

        await #expect(throws: ExchangeRatesError.unavailable) {
            try await sut(rates: ["MXN"])
        }
    }
}

private struct StubExchangeRateRepository: ExchangeRateRepository {
    let fetchResult: Result<ExchangeRatesSnapshot, ExchangeRatesError>

    func fetchLatestRates(for _: [String]) async throws(ExchangeRatesError) -> ExchangeRatesSnapshot {
        try fetchResult.get()
    }
}
