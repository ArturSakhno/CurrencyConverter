import Foundation

nonisolated struct RemoteExchangeRateRepository: ExchangeRateRepository {
    let apiClient: TickersAPIClient

    nonisolated func fetchLatestRates(for quoteCurrencyCodes: [String]) async throws -> ExchangeRatesSnapshot {
        let tickers = try await apiClient.fetchTickers(quoteCurrencyCodes: quoteCurrencyCodes)
        let rates = tickers.compactMap { $0?.toDomain() }
        return ExchangeRatesSnapshot(rates: rates, fetchedAt: Date())
    }
}

private extension TickerDTO {
    nonisolated func toDomain() -> ExchangeRate? {
        guard
            let askDecimal = Decimal(string: ask),
            let bidDecimal = Decimal(string: bid),
            let quoteCode = book.split(separator: "_").last
        else { return nil }
        return ExchangeRate(
            quoteCurrencyCode: quoteCode.uppercased(),
            ask: askDecimal,
            bid: bidDecimal
        )
    }
}
