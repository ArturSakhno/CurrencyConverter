import Foundation

nonisolated struct RemoteExchangeRateRepository: ExchangeRateRepository {
    let apiClient: TickersAPIClient
    let store: ExchangeRatesSnapshotStore

    func fetchLatestRates(for quoteCurrencyCodes: [String]) async throws -> ExchangeRatesSnapshot {
        let rates = try await apiClient.fetchTickers(quoteCurrencyCodes: quoteCurrencyCodes)
        let snapshot = ExchangeRatesSnapshot(rates: rates, fetchedAt: Date())
        // A failed save must not fail a successful fetch - the rates are still fresh.
        // TODO: log the error once logging lands.
        try? store.save(snapshot)
        return snapshot
    }

    func lastCachedSnapshot() -> ExchangeRatesSnapshot? {
        store.load()
    }
}
