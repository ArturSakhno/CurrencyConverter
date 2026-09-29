import Foundation

nonisolated struct RemoteExchangeRateRepository: ExchangeRateRepository {
    let apiClient: TickersAPIClient
    let store: ExchangeRatesSnapshotStore

    func fetchLatestRates(base: Currency, quotes: [Currency]) async throws -> ExchangeRatesSnapshot {
        // Throws when nothing in the response is usable, so an empty snapshot is never saved.
        let rates = try await apiClient.fetchTickers(base: base, quotes: quotes)
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
