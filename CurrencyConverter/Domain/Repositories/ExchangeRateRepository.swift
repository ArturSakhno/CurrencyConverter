protocol ExchangeRateRepository: Sendable {
    /// A successful fetch is expected to also update the local cache, so
    /// `lastCachedSnapshot()` reflects it afterward.
    nonisolated func fetchLatestRates(for quoteCurrencyCodes: [String]) async throws -> ExchangeRatesSnapshot
    nonisolated func lastCachedSnapshot() -> ExchangeRatesSnapshot?
}
