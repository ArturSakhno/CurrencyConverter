@testable import CurrencyConverter
import Foundation
import Networking
import Testing

struct RemoteExchangeRateRepositoryTests {
    private let mxnRate = ExchangeRate(
        quoteCurrencyCode: "MXN",
        ask: Decimal(string: "18.42")!,
        bid: Decimal(string: "18.40")!
    )

    @Test func successfulFetchReturnsRatesStampedWithFetchTime() async throws {
        let ticker = TickerDTO(ask: "18.42", bid: "18.40", book: "usdc_mxn")
        let sut = RemoteExchangeRateRepository(apiClient: StubTickersAPIClient(result: .success([ticker])))
        let before = Date()

        let snapshot = try await sut.fetchLatestRates(for: ["MXN"])

        #expect(snapshot.rates == [mxnRate])
        #expect(snapshot.fetchedAt >= before)
    }

    @Test func mapsByBookAfterDroppingNullAndInvalidTickers() async throws {
        let tickers: [TickerDTO?] = [
            TickerDTO(ask: "1551.0000000000", bid: "1539.4290300000", book: "usdc_ars"),
            nil,
            TickerDTO(ask: "invalid", bid: "18.40", book: "usdc_mxn"),
            TickerDTO(ask: "18.4105000000", bid: "18.4069700000", book: "usdc_mxn"),
        ]
        let sut = RemoteExchangeRateRepository(apiClient: StubTickersAPIClient(result: .success(tickers)))

        let snapshot = try await sut.fetchLatestRates(for: ["ARS", "EUR", "MXN"])

        #expect(snapshot.rates.count == 2)
        #expect(snapshot.rates[0].quoteCurrencyCode == "ARS")
        #expect(snapshot.rates[0].bid == Decimal(string: "1539.4290300000"))
        #expect(snapshot.rates[1].quoteCurrencyCode == "MXN")
        #expect(snapshot.rates[1].ask == Decimal(string: "18.4105000000"))
    }

    @Test func failedFetchThrows() async {
        let apiClient = StubTickersAPIClient(result: .failure(.transport(URLError(.notConnectedToInternet))))
        let sut = RemoteExchangeRateRepository(apiClient: apiClient)

        await #expect(throws: NetworkError.self) {
            try await sut.fetchLatestRates(for: ["MXN"])
        }
    }
}

private struct StubTickersAPIClient: TickersAPIClient {
    let result: Result<[TickerDTO?], NetworkError>

    func fetchTickers(quoteCurrencyCodes _: [String]) async throws(NetworkError) -> [TickerDTO?] {
        try result.get()
    }
}
