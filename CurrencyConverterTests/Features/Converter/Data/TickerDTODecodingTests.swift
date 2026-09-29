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
        #expect(rates.first?.quoteCurrencyCode == "ARS")
    }
}
