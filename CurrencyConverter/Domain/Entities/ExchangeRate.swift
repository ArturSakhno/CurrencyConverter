import Foundation

nonisolated struct ExchangeRate: Codable, Equatable, Sendable {
    let quoteCurrencyCode: String
    let ask: Decimal
    let bid: Decimal
}
