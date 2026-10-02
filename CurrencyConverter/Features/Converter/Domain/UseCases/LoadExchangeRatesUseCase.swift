nonisolated protocol LoadExchangeRatesUseCase: Sendable {
    func callAsFunction(rates quoteCurrencyCodes: [String]) async throws(ExchangeRatesError) -> ExchangeRatesSnapshot
}

struct DefaultLoadExchangeRatesUseCase: LoadExchangeRatesUseCase {
    let repository: ExchangeRateRepository

    func callAsFunction(rates quoteCurrencyCodes: [String]) async throws(ExchangeRatesError) -> ExchangeRatesSnapshot {
        try await repository.fetchLatestRates(for: quoteCurrencyCodes)
    }
}
