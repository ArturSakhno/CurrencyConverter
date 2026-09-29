nonisolated enum RatesLoadResult: Equatable, Sendable {
    case loaded(ExchangeRatesSnapshot, isFresh: Bool)
    case unavailable
}

nonisolated protocol LoadExchangeRatesUseCase: Sendable {
    func load() async -> RatesLoadResult
}

struct DefaultLoadExchangeRatesUseCase: LoadExchangeRatesUseCase {
    let repository: ExchangeRateRepository
    let baseCurrency: Currency
    let quoteCurrencies: [Currency]

    func load() async -> RatesLoadResult {
        do {
            let snapshot = try await repository.fetchLatestRates(base: baseCurrency, quotes: quoteCurrencies)
            return .loaded(snapshot, isFresh: true)
        } catch {
            if let cached = repository.lastCachedSnapshot() {
                return .loaded(cached, isFresh: false)
            }
            return .unavailable
        }
    }
}
