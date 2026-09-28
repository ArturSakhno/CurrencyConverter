import Foundation

nonisolated struct RemoteExchangeRateRepository: ExchangeRateRepository {
    let apiClient: TickersAPIClient

    func fetchLatestRates(for quoteCurrencyCodes: [String]) async throws -> ExchangeRatesSnapshot {
        let rates = try await apiClient.fetchTickers(quoteCurrencyCodes: quoteCurrencyCodes)
        return ExchangeRatesSnapshot(rates: rates, fetchedAt: Date())
    }

    /// Interim: always nil until roadmap item 3 adds a real cache store.
    nonisolated func lastCachedSnapshot() -> ExchangeRatesSnapshot? {
        nil
    }
}
