@testable import CurrencyConverter
import Testing

struct CurrencyCatalogUseCaseTests {
    @Test func returnsTheRepositorysCurrencies() async {
        let currencies = [Currency(code: "MXN"), Currency(code: "EURC"), Currency(code: "ARS")]
        let sut = DefaultCurrencyCatalogUseCase(repository: StubCurrencyCatalogRepository(currencies: currencies))

        #expect(await sut() == currencies)
    }
}

private struct StubCurrencyCatalogRepository: CurrencyCatalogRepository {
    let currencies: [Currency]

    func availableQuoteCurrencies() -> [Currency] {
        currencies
    }
}
