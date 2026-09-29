import Foundation

/// Presentation-only mapping from a `Currency.code` to the strings and asset name
/// shown on screen. Domain stays UI-agnostic; this is where "EURC" becomes "EURc"
/// and picks up its subtitle/symbol/flag.
///
/// `nonisolated` even though it lives in Presentation: this lets non-`@MainActor`
/// unit tests call `.info(for:)` synchronously, matching `AmountInputSanitizer`.
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
            subtitle: String(localized: "Digital dollars"),
            currencySymbol: "$",
            flagAssetName: "us"
        ),
        "MXN": CurrencyDisplayInfo(
            displayCode: "MXN",
            subtitle: String(localized: "Mexican pesos"),
            currencySymbol: "$",
            flagAssetName: "mxn"
        ),
        "EURC": CurrencyDisplayInfo(
            displayCode: "EURc",
            subtitle: String(localized: "Digital euros"),
            currencySymbol: "€",
            flagAssetName: "eur"
        ),
        "ARS": CurrencyDisplayInfo(
            displayCode: "ARS",
            subtitle: String(localized: "Argentine pesos"),
            currencySymbol: "$",
            flagAssetName: "ars"
        ),
        "COP": CurrencyDisplayInfo(
            displayCode: "COP",
            subtitle: String(localized: "Colombian pesos"),
            currencySymbol: "$",
            flagAssetName: "cop"
        ),
        "BRL": CurrencyDisplayInfo(
            displayCode: "BRL",
            subtitle: String(localized: "Brazilian reais"),
            currencySymbol: "R$",
            flagAssetName: "brl"
        ),
    ]
}
