import Foundation

nonisolated struct RemoteExchangeRateRepository: ExchangeRateRepository {
    let apiClient: TickersAPIClient

    nonisolated func fetchLatestRates(for quoteCurrencyCodes: [String]) async throws -> ExchangeRatesSnapshot {
        let tickers = try await apiClient.fetchTickers(quoteCurrencyCodes: quoteCurrencyCodes)
        let rates = tickers.compactMap { $0?.toDomain() }
        return ExchangeRatesSnapshot(rates: rates, fetchedAt: Date())
    }
}
