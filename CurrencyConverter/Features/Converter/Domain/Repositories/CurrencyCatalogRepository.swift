nonisolated protocol CurrencyCatalogRepository: Sendable {
    func availableQuoteCurrencies() async -> [Currency]
}
