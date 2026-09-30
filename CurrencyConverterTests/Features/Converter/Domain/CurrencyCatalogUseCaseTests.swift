@testable import CurrencyConverter
import Testing

struct CurrencyCatalogUseCaseTests {
    @Test func availableQuoteCurrenciesReturnsCurrenciesFromRepository() {
        let currencies = [Currency(code: "MXN"), Currency(code: "EURC"), Currency(code: "ARS")]
        let repository = StubCurrencyCatalogRepository(
            currencies: currencies,
            base: Currency(code: "USDC"),
            defaultQuote: currencies[0]
        )
        let sut = DefaultCurrencyCatalogUseCase(repository: repository)

        #expect(sut.availableQuoteCurrencies() == currencies)
    }

    @Test func baseCurrencyReturnsRepositoryValue() {
        let base = Currency(code: "USDC")
        let repository = StubCurrencyCatalogRepository(currencies: [], base: base, defaultQuote: base)
        let sut = DefaultCurrencyCatalogUseCase(repository: repository)

        #expect(sut.baseCurrency() == base)
    }

    @Test func defaultQuoteCurrencyReturnsRepositoryValue() {
        let defaultQuote = Currency(code: "MXN")
        let repository = StubCurrencyCatalogRepository(
            currencies: [defaultQuote],
            base: Currency(code: "USDC"),
            defaultQuote: defaultQuote
        )
        let sut = DefaultCurrencyCatalogUseCase(repository: repository)

        #expect(sut.defaultQuoteCurrency() == defaultQuote)
    }
}

private struct StubCurrencyCatalogRepository: CurrencyCatalogRepository {
    let currencies: [Currency]
    let base: Currency
    let defaultQuote: Currency

    func availableQuoteCurrencies() -> [Currency] {
        currencies
    }

    func baseCurrency() -> Currency {
        base
    }

    func defaultQuoteCurrency() -> Currency {
        defaultQuote
    }
}
