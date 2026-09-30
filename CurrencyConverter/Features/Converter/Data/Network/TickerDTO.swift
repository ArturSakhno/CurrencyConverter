import Foundation

/// The API also sends each quote's `date`. The app ignores it: refreshes are timed from when
/// a response arrives, and "Rates as of" shows when the app received the rates.
nonisolated struct TickerDTO: Decodable {
    let ask: String
    let bid: String
    let book: String
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
