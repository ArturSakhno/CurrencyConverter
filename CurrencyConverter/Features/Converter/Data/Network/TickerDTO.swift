import Foundation

nonisolated struct TickerDTO: Decodable {
    let ask: String
    let bid: String
    let book: String
    /// Nanosecond precision, no timezone. Kept as a raw string for possible future
    /// debugging/logging use — not parsed into `Date`. The app's own "rates as of"
    /// timestamp uses client-capture time instead, stamped by the repository on a
    /// successful fetch, since this field is awkward to parse reliably and nothing
    /// user-visible depends on it.
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
            bid: bidDecimal
        )
    }
}
