import Foundation

nonisolated enum Localized {
    nonisolated enum Common {
        static let close = LocalizedStringResource(
            "common.close",
            comment: "Accessibility label for a close button"
        )

        static let retry = LocalizedStringResource(
            "common.retry",
            comment: "Button that tries a failed operation again"
        )
    }

    nonisolated enum Converter {
        static let title = LocalizedStringResource(
            "converter.title",
            comment: "Main converter screen title"
        )

        static let loadingRates = LocalizedStringResource(
            "converter.loadingRates",
            comment: "Accessibility label for the loading converter"
        )

        static let chooseCurrency = LocalizedStringResource(
            "converter.chooseCurrency",
            comment: "Navigation title for the currency picker sheet"
        )

        static let rateUnavailable = LocalizedStringResource(
            "converter.rateUnavailable",
            comment: "Shown when the selected currency has no exchange rate"
        )

        static let noConnectionTitle = LocalizedStringResource(
            "converter.noConnection.title",
            comment: "Title when the first exchange rate request fails"
        )

        static let noConnectionMessage = LocalizedStringResource(
            "converter.noConnection.message",
            comment: "Instructions shown when the first exchange rate request fails"
        )

        static let currencyLoadErrorTitle = LocalizedStringResource(
            "converter.currencyLoadError.title",
            comment: "Title when the currency list cannot be loaded"
        )

        static let currencyLoadErrorMessage = LocalizedStringResource(
            "converter.currencyLoadError.message",
            comment: "Instructions when the currency list cannot be loaded"
        )

        static func ratesAsOf(_ time: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "converter.ratesAsOf \(time)",
                comment: "Caption under the screen title; the value is the local time the rates were fetched"
            )
        }

        static func amountIn(_ currencyCode: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "converter.amountIn \(currencyCode)",
                comment: "Accessibility label for an amount entry field; the value is the displayed currency code"
            )
        }

        static func rateQuote(baseCode: String, rate: String, quoteCode: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "converter.rateQuote \(baseCode) \(rate) \(quoteCode)",
                comment: "Exchange rate; values are the base currency code, rate, and quote currency code"
            )
        }

        nonisolated enum CurrencyNames {
            static let digitalDollars = LocalizedStringResource("converter.currency.digitalDollars")
            static let digitalEuros = LocalizedStringResource("converter.currency.digitalEuros")
            static let mexicanPesos = LocalizedStringResource("converter.currency.mexicanPesos")
            static let argentinePesos = LocalizedStringResource("converter.currency.argentinePesos")
            static let colombianPesos = LocalizedStringResource("converter.currency.colombianPesos")
            static let brazilianReais = LocalizedStringResource("converter.currency.brazilianReais")
        }
    }
}
