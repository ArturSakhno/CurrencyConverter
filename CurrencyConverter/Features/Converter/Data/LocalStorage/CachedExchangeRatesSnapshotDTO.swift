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
                quoteCurrencyCode: $0.quoteCurrency.code,
                ask: $0.ask.description,
                bid: $0.bid.description,
                quotedAt: $0.quotedAt
            )
        }
        fetchedAt = snapshot.fetchedAt
    }

    /// `nil` if the file holds no rates or any stored rate doesn't parse or has a non-positive
    /// price, so a damaged file reads as "no cache" rather than showing a partial set of rates.
    nonisolated func toDomain() -> ExchangeRatesSnapshot? {
        guard !rates.isEmpty else { return nil }
        var domainRates: [ExchangeRate] = []
        for rate in rates {
            guard let ask = Decimal(string: rate.ask), let bid = Decimal(string: rate.bid) else { return nil }
            let domainRate = ExchangeRate(
                quoteCurrency: Currency(code: rate.quoteCurrencyCode),
                ask: ask,
                bid: bid,
                quotedAt: rate.quotedAt
            )
            guard domainRate.hasUsablePrices else { return nil }
            domainRates.append(domainRate)
        }
        return ExchangeRatesSnapshot(rates: domainRates, fetchedAt: fetchedAt)
    }
}
