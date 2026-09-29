nonisolated protocol CurrencyCatalogUseCase: Sendable {
    func availableQuoteCurrencies() -> [Currency]
    func baseCurrency() -> Currency
    func defaultQuoteCurrency() -> Currency
}

struct DefaultCurrencyCatalogUseCase: CurrencyCatalogUseCase {
    let repository: CurrencyCatalogRepository

    func availableQuoteCurrencies() -> [Currency] {
        repository.availableQuoteCurrencies()
    }

    func baseCurrency() -> Currency {
        repository.baseCurrency()
    }

    func defaultQuoteCurrency() -> Currency {
        repository.defaultQuoteCurrency()
    }
}
