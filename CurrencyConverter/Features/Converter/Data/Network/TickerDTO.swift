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
    /// Returns `nil` (rather than throwing) for a ticker that isn't a usable rate for one of
    /// `quotes` against `base`, so one bad entry can be dropped by the caller without failing
    /// the whole batch - the same tolerance already needed for the API's null array elements.
    /// `book` must be exactly `<base>_<quote>` (e.g. `usdc_mxn`) and both prices positive.
    nonisolated func toDomain(base: Currency, quotes: [Currency]) -> ExchangeRate? {
        let pair = book.split(separator: "_", omittingEmptySubsequences: false)
        guard
            pair.count == 2,
            pair[0].uppercased() == base.code,
            let quoteCurrency = quotes.first(where: { $0.code == pair[1].uppercased() }),
            let askDecimal = Self.price(ask),
            let bidDecimal = Self.price(bid)
        else { return nil }
        let rate = ExchangeRate(
            quoteCurrency: quoteCurrency,
            ask: askDecimal,
            bid: bidDecimal,
            quotedAt: Self.parseDate(date)
        )
        return rate.hasUsablePrices ? rate : nil
    }

    /// `Decimal(string:)` stops at the first character it can't read ("18.4x" parses as 18.4),
    /// so the whole string is checked first: digits with at most one ".".
    private nonisolated static func price(_ string: String) -> Decimal? {
        guard string.allSatisfy({ $0.isASCII && ($0.isNumber || $0 == ".") }),
              string.count(where: { $0 == "." }) <= 1
        else { return nil }
        return Decimal(string: string)
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
