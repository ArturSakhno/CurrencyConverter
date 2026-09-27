nonisolated enum RatesLoadResult: Equatable, Sendable {
    case loaded(ExchangeRatesSnapshot, isFresh: Bool)
    case unavailable
}

protocol LoadExchangeRatesUseCase: Sendable {
    nonisolated func load() async -> RatesLoadResult
}

nonisolated struct DefaultLoadExchangeRatesUseCase: LoadExchangeRatesUseCase {
    let repository: ExchangeRateRepository
    let quoteCurrencyCodes: [String]

    nonisolated func load() async -> RatesLoadResult {
        do {
            let snapshot = try await repository.fetchLatestRates(for: quoteCurrencyCodes)
            return .loaded(snapshot, isFresh: true)
        } catch {
            if let cached = repository.lastCachedSnapshot() {
                return .loaded(cached, isFresh: false)
            }
            return .unavailable
        }
    }
}
