import Foundation

nonisolated struct CurrencyDisplayInfo: Equatable, Sendable {
    let displayCode: String
    let subtitle: String
    let currencySymbol: String?
    let flagAssetName: String?

    nonisolated static func info(for currency: Currency) -> CurrencyDisplayInfo {
        table[currency.code] ?? CurrencyDisplayInfo(
            displayCode: currency.code,
            subtitle: "",
            currencySymbol: nil,
            flagAssetName: nil
        )
    }

    private static let table: [String: CurrencyDisplayInfo] = [
        "USDC": CurrencyDisplayInfo(
            displayCode: "USDc",
            subtitle: String(localized: Localized.Converter.CurrencyNames.digitalDollars),
            currencySymbol: "$",
            flagAssetName: "us"
        ),
        "MXN": CurrencyDisplayInfo(
            displayCode: "MXN",
            subtitle: String(localized: Localized.Converter.CurrencyNames.mexicanPesos),
            currencySymbol: "$",
            flagAssetName: "mxn"
        ),
        "EURC": CurrencyDisplayInfo(
            displayCode: "EURc",
            subtitle: String(localized: Localized.Converter.CurrencyNames.digitalEuros),
            currencySymbol: "€",
            flagAssetName: "eur"
        ),
        "ARS": CurrencyDisplayInfo(
            displayCode: "ARS",
            subtitle: String(localized: Localized.Converter.CurrencyNames.argentinePesos),
            currencySymbol: "$",
            flagAssetName: "ars"
        ),
        "COP": CurrencyDisplayInfo(
            displayCode: "COP",
            subtitle: String(localized: Localized.Converter.CurrencyNames.colombianPesos),
            currencySymbol: "$",
            flagAssetName: "cop"
        ),
        "BRL": CurrencyDisplayInfo(
            displayCode: "BRL",
            subtitle: String(localized: Localized.Converter.CurrencyNames.brazilianReais),
            currencySymbol: "R$",
            flagAssetName: "brl"
        ),
    ]
}
