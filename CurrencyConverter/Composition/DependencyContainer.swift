struct DependencyContainer {
    let convertUseCase: ConvertCurrencyUseCase
    let loadRatesUseCase: LoadExchangeRatesUseCase

    init() {
        let repository = RemoteExchangeRateRepository(apiClient: URLSessionTickersAPIClient())
        convertUseCase = DefaultConvertCurrencyUseCase()
        loadRatesUseCase = DefaultLoadExchangeRatesUseCase(
            repository: repository,
            quoteCurrencyCodes: CurrencyCatalog.availableQuoteCurrencies.map(\.code)
        )
    }
}
