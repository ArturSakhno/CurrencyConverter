nonisolated protocol ExchangeRateRepository: Sendable {
    func fetchLatestRates(for quoteCurrencyCodes: [String]) async throws -> ExchangeRatesSnapshot
}
