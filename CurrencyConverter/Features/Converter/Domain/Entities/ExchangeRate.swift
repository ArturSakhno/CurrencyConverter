import Foundation

nonisolated struct ExchangeRate: Equatable, Sendable {
    let quoteCurrencyCode: String
    let ask: Decimal
    let bid: Decimal
}
