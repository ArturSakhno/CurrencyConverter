import Networking

struct DependencyContainer {
    let convertUseCase: ConvertCurrencyUseCase
    let loadRatesUseCase: LoadExchangeRatesUseCase
    let currencyCatalogUseCase: CurrencyCatalogUseCase

    init() {
        let repository = RemoteExchangeRateRepository(
            apiClient: DefaultTickersAPIClient(networkClient: URLSessionNetworkClient())
        )
        let currencyCatalogRepository = FallbackCurrencyCatalogRepository()

        convertUseCase = DefaultConvertCurrencyUseCase()
        currencyCatalogUseCase = DefaultCurrencyCatalogUseCase(repository: currencyCatalogRepository)
        loadRatesUseCase = DefaultLoadExchangeRatesUseCase(repository: repository)
    }

    func makeConverterViewModel() -> ConverterViewModel {
        ConverterViewModel(
            convertUseCase: convertUseCase,
            loadRatesUseCase: loadRatesUseCase,
            loadAvailableCurrenciesUseCase: currencyCatalogUseCase,
            baseCurrency: CurrencyCatalog.base
        )
    }
}
