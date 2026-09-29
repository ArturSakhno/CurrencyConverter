nonisolated struct FallbackCurrencyCatalogRepository: CurrencyCatalogRepository {
    func availableQuoteCurrencies() -> [Currency] {
        CurrencyCatalog.availableQuoteCurrencies
    }

    func baseCurrency() -> Currency {
        CurrencyCatalog.base
    }

    func defaultQuoteCurrency() -> Currency {
        CurrencyCatalog.defaultQuote
    }
}
