import Foundation

nonisolated protocol ConvertCurrencyUseCase: Sendable {
    func quoteAmount(fromBase baseAmount: Decimal, rate: Decimal) -> Decimal
    func baseAmount(fromQuote quoteAmount: Decimal, rate: Decimal) -> Decimal
}

struct DefaultConvertCurrencyUseCase: ConvertCurrencyUseCase {
    func quoteAmount(fromBase baseAmount: Decimal, rate: Decimal) -> Decimal {
        baseAmount * rate
    }

    func baseAmount(fromQuote quoteAmount: Decimal, rate: Decimal) -> Decimal {
        quoteAmount / rate
    }
}
