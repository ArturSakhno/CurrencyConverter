import Foundation

nonisolated enum CurrencySide: Sendable {
    case base
    case quote
}

nonisolated struct DefaultConvertCurrencyUseCase {
    func price(of quote: Currency, direction: TradeDirection, in snapshot: ExchangeRatesSnapshot) -> Decimal? {
        snapshot.rate(for: quote)?.price(for: direction)
    }

    func convert(
        _ amount: Decimal,
        from side: CurrencySide,
        quote: Currency,
        direction: TradeDirection,
        in snapshot: ExchangeRatesSnapshot
    ) -> Decimal? {
        guard let price = price(of: quote, direction: direction, in: snapshot) else { return nil }
        return switch side {
        case .base: amount * price
        case .quote: amount / price
        }
    }
}
