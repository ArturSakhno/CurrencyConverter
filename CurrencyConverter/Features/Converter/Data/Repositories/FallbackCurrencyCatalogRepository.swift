nonisolated struct FallbackCurrencyCatalogRepository: CurrencyCatalogRepository {
    func availableQuoteCurrencies() async -> [Currency] {
        CurrencyCatalog.availableQuoteCurrencies
    }
}
