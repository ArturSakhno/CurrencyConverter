nonisolated struct MockCurrencyCatalogRepository: CurrencyCatalogRepository {
    /// Explicit stand-in for the real `/v1/currencies` endpoint, which always returns
    /// HTTP 403 (see CLAUDE.md). Not test scaffolding - this is the production
    /// implementation until that endpoint becomes usable, at which point only this
    /// type changes.
    nonisolated func availableQuoteCurrencies() -> [Currency] {
        CurrencyCatalog.availableQuoteCurrencies
    }

    nonisolated func baseCurrency() -> Currency {
        CurrencyCatalog.base
    }

    nonisolated func defaultQuoteCurrency() -> Currency {
        CurrencyCatalog.defaultQuote
    }
}
