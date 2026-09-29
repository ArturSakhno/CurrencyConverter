@testable import CurrencyConverter
import Foundation
import Testing

struct TickerDTODecodingTests {
    private let mxn = Currency(code: "MXN")
    private let ars = Currency(code: "ARS")

    private func response(status: Int = 200) throws -> HTTPURLResponse {
        let url = try #require(URL(string: "https://api.dolarapp.dev/v1/tickers"))
        return try #require(HTTPURLResponse(
            url: url,
            statusCode: status,
            httpVersion: nil,
            headerFields: ["x-correlation-id": "corr-1"]
        ))
    }

    private func decode(
        _ json: String,
        quotes: [Currency] = CurrencyCatalog.availableQuoteCurrencies
    ) throws -> [ExchangeRate] {
        try URLSessionTickersAPIClient.rates(
            from: Data(json.utf8),
            response: response(),
            base: CurrencyCatalog.base,
            quotes: quotes
        )
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
        #expect(rates.contains { $0.quoteCurrency == mxn && $0.ask == Decimal(string: "18.4105000000") })
        #expect(rates.contains { $0.quoteCurrency == ars && $0.bid == Decimal(string: "1539.4290300000") })
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
        #expect(rates.contains { $0.quoteCurrency == ars })
        #expect(rates.contains { $0.quoteCurrency == mxn })
    }

    @Test func parsesDateAsUTCWithFractionalSeconds() throws {
        let json = """
        [{"ask": "18.41", "bid": "18.40", "book": "usdc_mxn", "date": "2026-09-29T10:37:52.798864882"}]
        """

        let quotedAt = try #require(try decode(json).first?.quotedAt)

        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = .gmt
        let expected = try #require(utc.date(from: DateComponents(
            year: 2026, month: 9, day: 29, hour: 10, minute: 37, second: 52
        ))).addingTimeInterval(0.798864882)
        #expect(abs(quotedAt.timeIntervalSince(expected)) < 0.000_001)
    }

    @Test func unparsableDateKeepsTheRateWithoutQuoteTime() throws {
        let json = """
        [{"ask": "18.41", "bid": "18.40", "book": "usdc_mxn", "date": "yesterday"}]
        """

        let rates = try decode(json)

        #expect(rates.count == 1)
        #expect(rates.first?.quotedAt == nil)
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
        #expect(rates.first?.quoteCurrency == ars)
    }

    // MARK: - Validation

    @Test(arguments: ["btc_mxn", "mxn", "usdc_mxn_ars", "usdc_", "_mxn", "usdcmxn"])
    func dropsTickerWhoseBookIsNotBaseUnderscoreQuote(book: String) throws {
        let json = """
        [
            {"ask": "18.41", "bid": "18.40", "book": "\(book)", "date": "2026-09-29T10:37:52.798864882"},
            {"ask": "1551.00", "bid": "1539.42", "book": "usdc_ars", "date": "2026-09-29T10:37:52.798864882"}
        ]
        """

        #expect(try decode(json).map(\.quoteCurrency) == [ars])
    }

    @Test func dropsTickerForACurrencyThatWasNotRequested() throws {
        let json = """
        [
            {"ask": "18.41", "bid": "18.40", "book": "usdc_mxn", "date": "2026-09-29T10:37:52.798864882"},
            {"ask": "1551.00", "bid": "1539.42", "book": "usdc_ars", "date": "2026-09-29T10:37:52.798864882"}
        ]
        """

        #expect(try decode(json, quotes: [mxn]).map(\.quoteCurrency) == [mxn])
    }

    @Test(arguments: [("0", "18.40"), ("18.41", "0.0000000000"), ("-18.41", "18.40"), ("18.4x", "18.40"), ("", "18.40")])
    func dropsTickerWithAnUnusablePrice(ask: String, bid: String) throws {
        let json = """
        [
            {"ask": "\(ask)", "bid": "\(bid)", "book": "usdc_mxn", "date": "2026-09-29T10:37:52.798864882"},
            {"ask": "1551.00", "bid": "1539.42", "book": "usdc_ars", "date": "2026-09-29T10:37:52.798864882"}
        ]
        """

        #expect(try decode(json).map(\.quoteCurrency) == [ars])
    }

    @Test func repeatedQuoteKeepsTheFirstTicker() throws {
        let json = """
        [
            {"ask": "18.41", "bid": "18.40", "book": "usdc_mxn", "date": "2026-09-29T10:37:52.798864882"},
            {"ask": "99.00", "bid": "98.00", "book": "usdc_mxn", "date": "2026-09-29T10:37:52.798864882"}
        ]
        """

        let rates = try decode(json)

        #expect(rates.count == 1)
        #expect(rates.first?.ask == Decimal(string: "18.41"))
    }

    /// The agreed partial-response policy: keep what was quoted, leave the rest missing.
    @Test func partialResponseKeepsTheCurrenciesThatWereQuoted() throws {
        let json = """
        [
            {"ask": "18.41", "bid": "18.40", "book": "usdc_mxn", "date": "2026-09-29T10:37:52.798864882"},
            null
        ]
        """

        let rates = try decode(json, quotes: [mxn, ars])

        #expect(rates.map(\.quoteCurrency) == [mxn])
    }

    @Test(arguments: ["[]", "[null, null]", #"[{"ask": "0", "bid": "0", "book": "usdc_mxn", "date": ""}]"#])
    func responseWithNoUsableRateThrows(json: String) throws {
        #expect(throws: APIError.noUsableRates(correlationID: "corr-1")) {
            try decode(json)
        }
    }

    @Test func non200StatusThrowsWithCorrelationID() throws {
        #expect(throws: APIError.unexpectedStatus(500, correlationID: "corr-1")) {
            try URLSessionTickersAPIClient.rates(
                from: Data("[]".utf8),
                response: response(status: 500),
                base: CurrencyCatalog.base,
                quotes: [mxn]
            )
        }
    }
}
