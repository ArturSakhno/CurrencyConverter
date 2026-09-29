import Foundation

nonisolated struct ExchangeRatesSnapshot: Equatable, Sendable {
    let rates: [ExchangeRate]
    let fetchedAt: Date

    /// When the server issued these quotes - the earliest across all rates, so a refresh is
    /// never scheduled later than the oldest one warrants. `nil` if no rate carries a time.
    var quotedAt: Date? {
        rates.compactMap(\.quotedAt).min()
    }
}
