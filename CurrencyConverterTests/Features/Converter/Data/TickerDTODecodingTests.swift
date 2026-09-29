@testable import CurrencyConverter
import Foundation
import Testing

struct TickerDTODecodingTests {
    private func decode(_ json: String) throws -> [ExchangeRate] {
        let dtos = try JSONDecoder().decode([TickerDTO?].self, from: Data(json.utf8))
        return dtos.compactMap { $0?.toDomain() }
    }

    @Test func decodesMultipleValidTickers() throws {
        let json = """
        [
            {"ask": "18.4105000000", "bid": "18.4069700000", "book": "usdc_mxn", "date": "2025-10-20T20:14:57.361483956"},
            {"ask": "1551.0000000000", "bid": "1539.4290300000", "book": "usdc_ars", "date": "2025-10-21T09:44:18.512194175"}
        ]
        """

        let rates = try decode(json)

        #expect(rates.count == 2)
        #expect(rates.contains { $0.quoteCurrencyCode == "MXN" && $0.ask == Decimal(string: "18.4105000000") })
        #expect(rates.contains { $0.quoteCurrencyCode == "ARS" && $0.bid == Decimal(string: "1539.4290300000") })
    }

    @Test func dropsNullElementWithoutMisassigningTheRest() throws {
        let json = """
        [
            {"ask": "1551.0000000000", "bid": "1539.4290300000", "book": "usdc_ars", "date": "2025-10-21T09:44:18.512194175"},
            null,
            {"ask": "18.4105000000", "bid": "18.4069700000", "book": "usdc_mxn", "date": "2025-10-20T20:14:57.361483956"}
        ]
        """

        let rates = try decode(json)

        #expect(rates.count == 2)
        #expect(rates.contains { $0.quoteCurrencyCode == "ARS" })
        #expect(rates.contains { $0.quoteCurrencyCode == "MXN" })
    }

    @Test func dropsTickerWithNonNumericAskOrBidWithoutFailingTheBatch() throws {
        let json = """
        [
            {"ask": "not-a-number", "bid": "18.4069700000", "book": "usdc_mxn", "date": "2025-10-20T20:14:57.361483956"},
            {"ask": "1551.0000000000", "bid": "1539.4290300000", "book": "usdc_ars", "date": "2025-10-21T09:44:18.512194175"}
        ]
        """

        let rates = try decode(json)

        #expect(rates.count == 1)
        #expect(rates.first?.quoteCurrencyCode == "ARS")
    }
}
