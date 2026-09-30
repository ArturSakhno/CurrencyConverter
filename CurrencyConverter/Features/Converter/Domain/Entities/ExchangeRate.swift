import Foundation

nonisolated struct ExchangeRate: Equatable, Sendable {
    let quoteCurrencyCode: String
    let ask: Decimal
    let bid: Decimal
}

/// Which way the base currency moves in a trade.
nonisolated enum TradeDirection: Sendable {
    /// The user gives base (USDc) and receives quote, at the bid.
    case sellingBase
    /// The user gives quote and receives base (USDc), at the ask.
    case buyingBase
}

extension ExchangeRate {
    /// Units of quote per one base unit that the user gets in `direction`.
    nonisolated func price(for direction: TradeDirection) -> Decimal {
        switch direction {
        case .sellingBase: bid
        case .buyingBase: ask
        }
    }
}
