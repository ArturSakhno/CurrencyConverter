nonisolated final class FallbackCurrencyCatalogRepository: CurrencyCatalogRepository {
    func availableQuoteCurrencies() async -> [Currency] {
        CurrencyCatalog.availableQuoteCurrencies
    }
}
