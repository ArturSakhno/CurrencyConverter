import Foundation

protocol ConvertCurrencyUseCase: Sendable {
    nonisolated func quoteAmount(fromBase baseAmount: Decimal, rate: Decimal) -> Decimal
    nonisolated func baseAmount(fromQuote quoteAmount: Decimal, rate: Decimal) -> Decimal
}

nonisolated struct DefaultConvertCurrencyUseCase: ConvertCurrencyUseCase {
    nonisolated func quoteAmount(fromBase baseAmount: Decimal, rate: Decimal) -> Decimal {
        baseAmount * rate
    }

    nonisolated func baseAmount(fromQuote quoteAmount: Decimal, rate: Decimal) -> Decimal {
        quoteAmount / rate
    }
}
