protocol CurrencyCatalogUseCase: Sendable {
    nonisolated func availableQuoteCurrencies() -> [Currency]
    nonisolated func baseCurrency() -> Currency
    nonisolated func defaultQuoteCurrency() -> Currency
}

nonisolated struct DefaultCurrencyCatalogUseCase: CurrencyCatalogUseCase {
    let repository: CurrencyCatalogRepository

    nonisolated func availableQuoteCurrencies() -> [Currency] {
        repository.availableQuoteCurrencies()
    }

    nonisolated func baseCurrency() -> Currency {
        repository.baseCurrency()
    }

    nonisolated func defaultQuoteCurrency() -> Currency {
        repository.defaultQuoteCurrency()
    }
}
