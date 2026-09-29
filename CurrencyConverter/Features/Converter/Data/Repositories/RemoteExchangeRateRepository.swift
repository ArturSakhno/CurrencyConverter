import Foundation

nonisolated struct RemoteExchangeRateRepository: ExchangeRateRepository {
    let apiClient: TickersAPIClient

    func fetchLatestRates(for quoteCurrencyCodes: [String]) async throws -> ExchangeRatesSnapshot {
        let rates = try await apiClient.fetchTickers(quoteCurrencyCodes: quoteCurrencyCodes)
        return ExchangeRatesSnapshot(rates: rates, fetchedAt: Date())
    }
}
