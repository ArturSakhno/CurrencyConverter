import Foundation

nonisolated struct ExchangeRate: Equatable, Sendable {
    let quoteCurrencyCode: String
    let ask: Decimal
    let bid: Decimal
}

nonisolated enum TradeDirection: Sendable {
    case sellingBase
    case buyingBase
}

extension ExchangeRate {
    nonisolated func price(for direction: TradeDirection) -> Decimal {
        switch direction {
        case .sellingBase: bid
        case .buyingBase: ask
        }
    }
}
