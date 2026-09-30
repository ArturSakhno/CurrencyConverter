nonisolated enum ExchangeRatesError: Error {
    case unavailable
}

nonisolated protocol ExchangeRateRepository: Sendable {
    func fetchLatestRates(for quoteCurrencyCodes: [String]) async throws(ExchangeRatesError) -> ExchangeRatesSnapshot
}
