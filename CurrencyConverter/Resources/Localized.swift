import Foundation

nonisolated enum Localized {
    nonisolated enum Common {
        static let retry = LocalizedStringResource(
            "common.retry",
            comment: "Button that tries a failed operation again"
        )
    }

    nonisolated enum Converter {
        nonisolated enum CurrencyNames {
            static let digitalDollars = LocalizedStringResource("converter.currency.digitalDollars")
            static let digitalEuros = LocalizedStringResource("converter.currency.digitalEuros")
            static let mexicanPesos = LocalizedStringResource("converter.currency.mexicanPesos")
            static let argentinePesos = LocalizedStringResource("converter.currency.argentinePesos")
            static let colombianPesos = LocalizedStringResource("converter.currency.colombianPesos")
            static let brazilianReais = LocalizedStringResource("converter.currency.brazilianReais")
        }

        static let title = LocalizedStringResource(
            "converter.title",
            comment: "Main converter screen title"
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
            comment: "Title when the first exchange rate request fails while the device is offline"
        )

        static let noConnectionMessage = LocalizedStringResource(
            "converter.noConnection.message",
            comment: "Instructions shown when the first exchange rate request fails while the device is offline"
        )

        static let unavailableTitle = LocalizedStringResource(
            "converter.unavailable.title",
            comment: "Generic title when the first load fails while the device is online"
        )

        static let unavailableMessage = LocalizedStringResource(
            "converter.unavailable.message",
            comment: "Generic instructions shown when the first load fails while the device is online"
        )

        static func ratesAsOf(_ time: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "converter.ratesAsOf \(time)",
                comment: "Caption under the screen title; the value is the local time the rates were fetched"
            )
        }

        static func rateQuote(baseCode: String, rate: String, quoteCode: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "converter.rateQuote \(baseCode) \(rate) \(quoteCode)",
                comment: "Exchange rate; values are the base currency code, rate, and quote currency code"
            )
        }
    }
}
