struct DependencyContainer {
    let convertUseCase: ConvertCurrencyUseCase
    let loadRatesUseCase: LoadExchangeRatesUseCase
    let currencyCatalogUseCase: CurrencyCatalogUseCase

    init() {
        let repository = RemoteExchangeRateRepository(apiClient: URLSessionTickersAPIClient())
        let currencyCatalogRepository = FallbackCurrencyCatalogRepository()

        convertUseCase = DefaultConvertCurrencyUseCase()
        currencyCatalogUseCase = DefaultCurrencyCatalogUseCase(repository: currencyCatalogRepository)
        loadRatesUseCase = DefaultLoadExchangeRatesUseCase(
            repository: repository,
            quoteCurrencyCodes: currencyCatalogUseCase.availableQuoteCurrencies().map(\.code)
        )
    }

    func makeConverterViewModel() -> ConverterViewModel {
        ConverterViewModel(convertUseCase: convertUseCase, loadRatesUseCase: loadRatesUseCase)
    }
}
