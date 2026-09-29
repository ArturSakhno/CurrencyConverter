nonisolated protocol ExchangeRateRepository: Sendable {
    /// Rates for `quotes` against `base`. A partial result is returned as is; one with no
    /// usable rate at all throws, so it can never replace the cached snapshot. A successful
    /// fetch is expected to also update the local cache, so `lastCachedSnapshot()` reflects it
    /// afterward.
    func fetchLatestRates(base: Currency, quotes: [Currency]) async throws -> ExchangeRatesSnapshot
    func lastCachedSnapshot() -> ExchangeRatesSnapshot?
}
