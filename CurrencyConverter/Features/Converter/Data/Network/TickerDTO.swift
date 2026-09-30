import Foundation

nonisolated struct TickerDTO: Decodable, Sendable {
    let ask: String
    let bid: String
    let book: String
}

extension TickerDTO {
    nonisolated func toDomain() -> ExchangeRate? {
        guard
            let askDecimal = Decimal(string: ask),
            let bidDecimal = Decimal(string: bid),
            let quoteCode = book.split(separator: "_").last
        else { return nil }
        return ExchangeRate(
            quoteCurrencyCode: quoteCode.uppercased(),
            ask: askDecimal,
            bid: bidDecimal
        )
    }
}
