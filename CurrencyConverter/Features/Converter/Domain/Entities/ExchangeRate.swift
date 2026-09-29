import Foundation

nonisolated struct ExchangeRate: Equatable, Sendable {
    let quoteCurrencyCode: String
    let ask: Decimal
    let bid: Decimal
    /// Server time the quote was issued at. `nil` when the API's timestamp couldn't be read.
    var quotedAt: Date?
}
