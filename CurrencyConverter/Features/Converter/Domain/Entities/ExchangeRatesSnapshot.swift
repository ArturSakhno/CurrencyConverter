import Foundation

nonisolated struct ExchangeRatesSnapshot: Equatable, Sendable {
    let rates: [ExchangeRate]
    let fetchedAt: Date

    func rate(for currency: Currency) -> ExchangeRate? {
        rates.first { $0.quoteCurrencyCode == currency.code }
    }
}
