@testable import CurrencyConverter
import Foundation
import Testing

struct ConvertCurrencyUseCaseTests {
    private let sut = DefaultConvertCurrencyUseCase()
    private let mxn = Currency(code: "MXN")
    // From strings: a float literal goes through Double, so 18.40 wouldn't be exact.
    private static let bid = Decimal(string: "18.40")!
    private static let ask = Decimal(string: "18.42")!
    private let snapshot = ExchangeRatesSnapshot(
        rates: [ExchangeRate(quoteCurrencyCode: "MXN", ask: Self.ask, bid: Self.bid)],
        fetchedAt: Date(timeIntervalSince1970: 0)
    )

    @Test(arguments: [(TradeDirection.sellingBase, bid), (.buyingBase, ask)])
    func priceIsTheBidWhenSellingBaseAndTheAskWhenBuying(direction: TradeDirection, expected: Decimal) {
        #expect(sut.price(of: mxn, direction: direction, in: snapshot) == expected)
    }

    @Test func baseAmountConvertsToQuoteAtTheDirectionsPrice() {
        #expect(sut.convert(100, from: .base, quote: mxn, direction: .sellingBase, in: snapshot) == 1840)
        #expect(sut.convert(100, from: .base, quote: mxn, direction: .buyingBase, in: snapshot) == 1842)
    }

    @Test func quoteAmountConvertsToBaseByDividing() {
        #expect(sut.convert(1842, from: .quote, quote: mxn, direction: .buyingBase, in: snapshot) == 100)
    }

    @Test func convertingThereAndBackReturnsTheAmount() throws {
        let quote = try #require(sut.convert(250, from: .base, quote: mxn, direction: .sellingBase, in: snapshot))
        #expect(sut.convert(quote, from: .quote, quote: mxn, direction: .sellingBase, in: snapshot) == 250)
    }

    @Test func missingRateGivesNil() {
        let ars = Currency(code: "ARS")
        #expect(sut.price(of: ars, direction: .sellingBase, in: snapshot) == nil)
        #expect(sut.convert(100, from: .base, quote: ars, direction: .sellingBase, in: snapshot) == nil)
    }
}
