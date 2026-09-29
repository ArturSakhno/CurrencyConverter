import Foundation

nonisolated struct ExchangeRate: Equatable, Sendable {
    let quoteCurrency: Currency
    let ask: Decimal
    let bid: Decimal
    /// Server time the quote was issued at. `nil` when the API's timestamp couldn't be read.
    var quotedAt: Date?
}

extension ExchangeRate {
    /// Both prices must be positive to convert with: zero would divide by zero and a negative
    /// price means nothing. Rates from the network and from the cache are both held to this.
    nonisolated var hasUsablePrices: Bool {
        ask > 0 && bid > 0
    }
}
