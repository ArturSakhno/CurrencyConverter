import Foundation

nonisolated final class RemoteExchangeRateRepository: ExchangeRateRepository {
    let apiClient: TickersAPIClient

    init(apiClient: TickersAPIClient) {
        self.apiClient = apiClient
    }

    nonisolated func fetchLatestRates(for quoteCurrencyCodes: [String]) async throws(ExchangeRatesError) -> ExchangeRatesSnapshot {
        guard let tickers = try? await apiClient.fetchTickers(quoteCurrencyCodes: quoteCurrencyCodes) else {
            throw .unavailable
        }
        let rates = tickers.compactMap { $0?.toDomain() }
        return ExchangeRatesSnapshot(rates: rates, fetchedAt: Date())
    }
}
