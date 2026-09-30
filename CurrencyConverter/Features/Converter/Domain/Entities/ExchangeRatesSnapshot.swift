import Foundation

nonisolated struct ExchangeRatesSnapshot: Equatable, Sendable {
    let rates: [ExchangeRate]
    let fetchedAt: Date
}
