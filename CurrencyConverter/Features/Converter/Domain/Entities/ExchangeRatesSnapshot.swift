import Foundation

nonisolated struct ExchangeRatesSnapshot: Equatable, Sendable {
    let rates: [ExchangeRate]
    let fetchedAt: Date

    /// When the server issued these quotes - the earliest across all rates, so a refresh is
    /// never scheduled later than the oldest one warrants. `nil` if no rate carries a time.
    var quotedAt: Date? {
        rates.compactMap(\.quotedAt).min()
    }

    /// `nil` when the API didn't quote `currency` in this fetch. A partial response is kept as
    /// is, so a currency can be missing while the others are fresh.
    func rate(for currency: Currency) -> ExchangeRate? {
        rates.first { $0.quoteCurrency == currency }
    }
}
