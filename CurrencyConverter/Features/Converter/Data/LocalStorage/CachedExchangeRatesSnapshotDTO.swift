import Foundation

/// On-disk shape of `ExchangeRatesSnapshot`. Rates are stored as strings because JSON decoding
/// of `Decimal` can go through `Double` and lose precision; a string round-trips exactly.
nonisolated struct CachedExchangeRatesSnapshotDTO: Codable {
    nonisolated struct Rate: Codable {
        let quoteCurrencyCode: String
        let ask: String
        let bid: String
        let quotedAt: Date?
    }

    let rates: [Rate]
    let fetchedAt: Date
}

extension CachedExchangeRatesSnapshotDTO {
    nonisolated init(_ snapshot: ExchangeRatesSnapshot) {
        rates = snapshot.rates.map {
            Rate(
                quoteCurrencyCode: $0.quoteCurrencyCode,
                ask: $0.ask.description,
                bid: $0.bid.description,
                quotedAt: $0.quotedAt
            )
        }
        fetchedAt = snapshot.fetchedAt
    }

    /// `nil` if any stored rate doesn't parse, so a damaged file reads as "no cache"
    /// rather than showing a partial set of rates.
    nonisolated func toDomain() -> ExchangeRatesSnapshot? {
        var domainRates: [ExchangeRate] = []
        for rate in rates {
            guard let ask = Decimal(string: rate.ask), let bid = Decimal(string: rate.bid) else { return nil }
            domainRates.append(ExchangeRate(
                quoteCurrencyCode: rate.quoteCurrencyCode,
                ask: ask,
                bid: bid,
                quotedAt: rate.quotedAt
            ))
        }
        return ExchangeRatesSnapshot(rates: domainRates, fetchedAt: fetchedAt)
    }
}
