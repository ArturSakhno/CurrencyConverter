@testable import CurrencyConverter
import Foundation
import Testing

struct TickerDTODecodingTests {
    @Test func decodesMultipleValidTickers() throws {
        let json = """
        [
            {"ask": "18.4105000000", "bid": "18.4069700000", "book": "usdc_mxn", "date": "2025-10-20T20:14:57.361483956"},
            {"ask": "1551.0000000000", "bid": "1539.4290300000", "book": "usdc_ars", "date": "2025-10-21T09:44:18.512194175"}
        ]
        """

        let tickers = try decode(json)

        #expect(tickers.count == 2)
        #expect(tickers[0]?.book == "usdc_mxn")
        #expect(tickers[0]?.ask == "18.4105000000")
        #expect(tickers[1]?.book == "usdc_ars")
        #expect(tickers[1]?.bid == "1539.4290300000")
    }

    @Test func preservesNullElementAndPositions() throws {
        let json = """
        [
            {"ask": "1551.0000000000", "bid": "1539.4290300000", "book": "usdc_ars", "date": "2025-10-21T09:44:18.512194175"},
            null,
            {"ask": "18.4105000000", "bid": "18.4069700000", "book": "usdc_mxn", "date": "2025-10-20T20:14:57.361483956"}
        ]
        """

        let tickers = try decode(json)

        #expect(tickers.count == 3)
        #expect(tickers[0]?.book == "usdc_ars")
        #expect(tickers[1]?.book == nil)
        #expect(tickers[2]?.book == "usdc_mxn")
    }

    @Test func decodesNonNumericPriceForRepositoryValidation() throws {
        let json = """
        [
            {"ask": "not-a-number", "bid": "18.4069700000", "book": "usdc_mxn", "date": "2025-10-20T20:14:57.361483956"},
            {"ask": "1551.0000000000", "bid": "1539.4290300000", "book": "usdc_ars", "date": "2025-10-21T09:44:18.512194175"}
        ]
        """

        let tickers = try decode(json)

        #expect(tickers.count == 2)
        #expect(tickers[0]?.ask == "not-a-number")
        #expect(tickers[1]?.book == "usdc_ars")
    }
}

private extension TickerDTODecodingTests {
    func decode(_ json: String) throws -> [TickerDTO?] {
        try JSONDecoder().decode([TickerDTO?].self, from: Data(json.utf8))
    }
}
