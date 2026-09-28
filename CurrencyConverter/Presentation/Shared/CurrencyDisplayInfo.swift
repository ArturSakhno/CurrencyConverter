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
            subtitle: String(localized: "Digital dollars", comment: "Subtitle for USDC"),
            currencySymbol: "$",
            flagAssetName: "us"
        ),
        "MXN": CurrencyDisplayInfo(
            displayCode: "MXN",
            subtitle: String(localized: "Mexican pesos", comment: "Subtitle for MXN"),
            currencySymbol: "$",
            flagAssetName: "mxn"
        ),
        "EURC": CurrencyDisplayInfo(
            displayCode: "EURc",
            subtitle: String(localized: "Digital euros", comment: "Subtitle for EURC"),
            currencySymbol: "€",
            flagAssetName: "eur"
        ),
        "ARS": CurrencyDisplayInfo(
            displayCode: "ARS",
            subtitle: String(localized: "Argentine pesos", comment: "Subtitle for ARS"),
            currencySymbol: "$",
            flagAssetName: "ars"
        ),
        "COP": CurrencyDisplayInfo(
            displayCode: "COP",
            subtitle: String(localized: "Colombian pesos", comment: "Subtitle for COP"),
            currencySymbol: "$",
            flagAssetName: "cop"
        ),
        "BRL": CurrencyDisplayInfo(
            displayCode: "BRL",
            subtitle: String(localized: "Brazilian reais", comment: "Subtitle for BRL"),
            currencySymbol: "R$",
            flagAssetName: "brl"
        ),
    ]
}
