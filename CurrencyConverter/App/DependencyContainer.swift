import Networking

struct DependencyContainer {
    let currencyCatalogRepository: CurrencyCatalogRepository
    let exchangeRateRepository: ExchangeRateRepository

    init() {
        exchangeRateRepository = RemoteExchangeRateRepository(
            apiClient: DefaultTickersAPIClient(networkClient: URLSessionNetworkClient())
        )
        currencyCatalogRepository = FallbackCurrencyCatalogRepository()
    }

    func makeConverterViewModel() -> ConverterViewModel {
        ConverterViewModel(
            convertUseCase: DefaultConvertCurrencyUseCase(),
            loadRatesUseCase: DefaultLoadExchangeRatesUseCase(repository: exchangeRateRepository),
            loadAvailableCurrenciesUseCase: DefaultCurrencyCatalogUseCase(repository: currencyCatalogRepository),
            networkMonitor: NWPathNetworkMonitor(),
            baseCurrency: CurrencyCatalog.base
        )
    }
}
