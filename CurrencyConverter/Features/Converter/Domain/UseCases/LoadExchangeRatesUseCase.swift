nonisolated enum RatesLoadResult: Equatable, Sendable {
    case loaded(ExchangeRatesSnapshot)
    case unavailable
}

nonisolated protocol LoadExchangeRatesUseCase: Sendable {
    func callAsFunction(rates quoteCurrencyCodes: [String]) async -> RatesLoadResult
}

struct DefaultLoadExchangeRatesUseCase: LoadExchangeRatesUseCase {
    let repository: ExchangeRateRepository

    func callAsFunction(rates quoteCurrencyCodes: [String]) async -> RatesLoadResult {
        guard let snapshot = try? await repository.fetchLatestRates(for: quoteCurrencyCodes) else {
            return .unavailable
        }
        return .loaded(snapshot)
    }
}
