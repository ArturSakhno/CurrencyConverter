import Foundation
import Testing
@testable import CurrencyConverter

struct ConvertCurrencyUseCaseTests {
    private let sut = DefaultConvertCurrencyUseCase()

    @Test func quoteAmountMultipliesBaseByRate() {
        let rate = Decimal(string: "18.4112")!
        let expected = Decimal(string: "1841.12")!
        #expect(sut.quoteAmount(fromBase: 100, rate: rate) == expected)
    }

    @Test func baseAmountDividesQuoteByRate() {
        #expect(sut.baseAmount(fromQuote: 1841, rate: 18.41) == 100)
    }

    @Test func quoteAmountAndBaseAmountAreInverses() {
        let quote = sut.quoteAmount(fromBase: 250, rate: 3387.24)
        #expect(sut.baseAmount(fromQuote: quote, rate: 3387.24) == 250)
    }

    @Test func zeroBaseAmountProducesZeroQuoteAmount() {
        #expect(sut.quoteAmount(fromBase: 0, rate: 18.41) == 0)
    }
}
