import Networking

struct DependencyContainer {
    let convertUseCase: ConvertCurrencyUseCase
    let loadRatesUseCase: LoadExchangeRatesUseCase
    let currencyCatalogUseCase: CurrencyCatalogUseCase
    let networkMonitor: NetworkMonitor

    init() {
        let repository = RemoteExchangeRateRepository(
            apiClient: DefaultTickersAPIClient(networkClient: URLSessionNetworkClient())
        )
        let currencyCatalogRepository = FallbackCurrencyCatalogRepository()

        convertUseCase = DefaultConvertCurrencyUseCase()
        currencyCatalogUseCase = DefaultCurrencyCatalogUseCase(repository: currencyCatalogRepository)
        loadRatesUseCase = DefaultLoadExchangeRatesUseCase(repository: repository)
        networkMonitor = NWPathNetworkMonitor()
    }

    func makeConverterViewModel() -> ConverterViewModel {
        ConverterViewModel(
            convertUseCase: convertUseCase,
            loadRatesUseCase: loadRatesUseCase,
            loadAvailableCurrenciesUseCase: currencyCatalogUseCase,
            networkMonitor: networkMonitor,
            baseCurrency: CurrencyCatalog.base
        )
    }
}
