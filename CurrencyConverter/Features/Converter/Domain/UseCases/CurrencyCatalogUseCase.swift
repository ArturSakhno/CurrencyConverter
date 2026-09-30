nonisolated protocol CurrencyCatalogUseCase: Sendable {
    func callAsFunction() async -> [Currency]
}

struct DefaultCurrencyCatalogUseCase: CurrencyCatalogUseCase {
    let repository: CurrencyCatalogRepository

    func callAsFunction() async -> [Currency] {
        await repository.availableQuoteCurrencies()
    }
}
