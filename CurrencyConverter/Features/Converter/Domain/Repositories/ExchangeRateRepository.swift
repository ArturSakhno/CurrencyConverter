nonisolated protocol ExchangeRateRepository: Sendable {
    /// A successful fetch is expected to also update the local cache, so
    /// `lastCachedSnapshot()` reflects it afterward.
    func fetchLatestRates(for quoteCurrencyCodes: [String]) async throws -> ExchangeRatesSnapshot
    func lastCachedSnapshot() -> ExchangeRatesSnapshot?
}
