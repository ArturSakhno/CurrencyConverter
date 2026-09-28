protocol CurrencyCatalogRepository: Sendable {
    nonisolated func availableQuoteCurrencies() -> [Currency]
    nonisolated func baseCurrency() -> Currency
    nonisolated func defaultQuoteCurrency() -> Currency
}
