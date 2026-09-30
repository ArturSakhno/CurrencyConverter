nonisolated enum RatesLoadResult: Equatable, Sendable {
    case loaded(ExchangeRatesSnapshot)
    case unavailable
}

nonisolated protocol LoadExchangeRatesUseCase: Sendable {
    func load() async -> RatesLoadResult
}

struct DefaultLoadExchangeRatesUseCase: LoadExchangeRatesUseCase {
    let repository: ExchangeRateRepository
    let quoteCurrencyCodes: [String]

    func load() async -> RatesLoadResult {
        guard let snapshot = try? await repository.fetchLatestRates(for: quoteCurrencyCodes) else {
            return .unavailable
        }
        return .loaded(snapshot)
    }
}
