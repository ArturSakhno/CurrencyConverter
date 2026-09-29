nonisolated protocol CurrencyCatalogRepository: Sendable {
    func availableQuoteCurrencies() -> [Currency]
    func baseCurrency() -> Currency
    func defaultQuoteCurrency() -> Currency
}
