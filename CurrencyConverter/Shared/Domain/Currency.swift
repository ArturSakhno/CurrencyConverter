nonisolated struct Currency: Identifiable, Hashable, Sendable {
    let code: String

    var id: String { code }
}

nonisolated enum CurrencyCatalog {
    static let base = Currency(code: "USDC")

    static let availableQuoteCurrencies: [Currency] = [
        Currency(code: "MXN"),
        Currency(code: "EURC"),
        Currency(code: "ARS"),
        Currency(code: "COP"),
        Currency(code: "BRL"),
    ]

    static let defaultQuote: Currency = availableQuoteCurrencies[0]
}
