import Foundation

/// Which side of the base/quote pair an amount is in.
nonisolated enum CurrencySide: Sendable {
    case base
    case quote
}

nonisolated protocol ConvertCurrencyUseCase: Sendable {
    /// Units of `quote` per one base unit in `direction`; `nil` when `snapshot` has no rate for it.
    func price(of quote: Currency, direction: TradeDirection, in snapshot: ExchangeRatesSnapshot) -> Decimal?

    /// `amount`, given in `side`, converted to the other side of the pair at the price for
    /// `direction`; `nil` when `snapshot` has no rate for `quote`.
    func convert(
        _ amount: Decimal,
        from side: CurrencySide,
        quote: Currency,
        direction: TradeDirection,
        in snapshot: ExchangeRatesSnapshot
    ) -> Decimal?
}

struct DefaultConvertCurrencyUseCase: ConvertCurrencyUseCase {
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
