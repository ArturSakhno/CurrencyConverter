import Foundation

nonisolated struct ExchangeRatesSnapshot: Codable, Equatable, Sendable {
    let rates: [ExchangeRate]
    let fetchedAt: Date
}
