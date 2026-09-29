/// Rates aren't persisted: a converter's rates only mean something live. `isFresh: false`
/// is never produced here; the view model uses it for rates it keeps on screen after a
/// failed refresh.
nonisolated enum RatesLoadResult: Equatable, Sendable {
    case loaded(ExchangeRatesSnapshot, isFresh: Bool)
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
        return .loaded(snapshot, isFresh: true)
    }
}
