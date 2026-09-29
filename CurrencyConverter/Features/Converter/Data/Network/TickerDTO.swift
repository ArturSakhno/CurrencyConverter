import Foundation

nonisolated struct TickerDTO: Decodable {
    let ask: String
    let bid: String
    let book: String
    /// When the server issued the quote, e.g. `2026-09-29T10:37:52.798864882`: UTC (it matches
    /// the response's HTTP `Date` header), nanosecond precision, no timezone suffix. Drives
    /// when the next refresh is due; "Rates as of" still shows client capture time.
    let date: String
}

extension TickerDTO {
    /// Returns `nil` (rather than throwing) for a ticker with a non-numeric ask/bid
    /// or an unrecognized `book` format, so one malformed entry can be dropped by the
    /// caller without failing the whole batch — the same tolerance already needed for
    /// the API's null array elements.
    nonisolated func toDomain() -> ExchangeRate? {
        guard
            let askDecimal = Decimal(string: ask),
            let bidDecimal = Decimal(string: bid),
            let quoteCode = book.split(separator: "_").last
        else { return nil }
        return ExchangeRate(
            quoteCurrencyCode: quoteCode.uppercased(),
            ask: askDecimal,
            bid: bidDecimal,
            quotedAt: Self.parseDate(date)
        )
    }

    /// Parses the API's timezone-less UTC timestamp. The seconds part goes through a fixed
    /// POSIX formatter; the fraction is added separately, because Foundation's ISO 8601
    /// parsers don't reliably accept 9 fractional digits. `nil` for anything unexpected -
    /// a missing timestamp must never drop the rate itself.
    nonisolated static func parseDate(_ string: String) -> Date? {
        let parts = string.split(separator: ".", maxSplits: 1)
        guard let whole = parts.first, let seconds = try? Date(String(whole), strategy: secondsStrategy) else { return nil }
        guard parts.count == 2 else { return seconds }
        guard let fraction = Double("0." + parts[1]) else { return nil }
        return seconds.addingTimeInterval(fraction)
    }

    private nonisolated static let secondsStrategy = Date.ParseStrategy(
        format: """
        \(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)T\
        \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)
        """,
        locale: Locale(identifier: "en_US_POSIX"),
        timeZone: .gmt
    )
}
