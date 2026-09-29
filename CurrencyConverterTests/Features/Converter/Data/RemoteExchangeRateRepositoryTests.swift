@testable import CurrencyConverter
import Foundation
import Testing

struct RemoteExchangeRateRepositoryTests {
    private let mxnRate = ExchangeRate(quoteCurrencyCode: "MXN", ask: 18.42, bid: 18.40)

    @Test func successfulFetchReturnsRatesStampedWithFetchTime() async throws {
        let sut = RemoteExchangeRateRepository(apiClient: StubTickersAPIClient(result: .success([mxnRate])))
        let before = Date()

        let snapshot = try await sut.fetchLatestRates(for: ["MXN"])

        #expect(snapshot.rates == [mxnRate])
        #expect(snapshot.fetchedAt >= before)
    }

    @Test func failedFetchThrows() async {
        let sut = RemoteExchangeRateRepository(apiClient: StubTickersAPIClient(result: .failure(.transport("offline"))))

        await #expect(throws: APIError.self) {
            try await sut.fetchLatestRates(for: ["MXN"])
        }
    }
}

private struct StubTickersAPIClient: TickersAPIClient {
    let result: Result<[ExchangeRate], APIError>

    func fetchTickers(quoteCurrencyCodes _: [String]) async throws -> [ExchangeRate] {
        try result.get()
    }
}
