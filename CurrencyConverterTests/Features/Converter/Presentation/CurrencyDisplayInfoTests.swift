@testable import CurrencyConverter
import Foundation
import Testing
import UIKit

struct CurrencyDisplayInfoTests {
    @Test(arguments: [CurrencyCatalog.base] + CurrencyCatalog.availableQuoteCurrencies)
    func everyCatalogEntryHasASubtitleAndSymbol(currency: Currency) {
        let info = CurrencyDisplayInfo.info(for: currency)
        #expect(!info.subtitle.isEmpty)
        #expect(info.currencySymbol != nil)
    }

    @MainActor
    @Test(arguments: CurrencyCatalog.availableQuoteCurrencies)
    func everyCatalogEntryHasABundledFlagAsset(currency: Currency) throws {
        let name = try #require(CurrencyDisplayInfo.info(for: currency).flagAssetName)
        #expect(UIImage(named: name) != nil)
    }

    @Test func eurcDisplaysAsEURcWithEuroSymbolAndEURFlag() {
        let info = CurrencyDisplayInfo.info(for: Currency(code: "EURC"))
        #expect(info.displayCode == "EURc")
        #expect(info.currencySymbol == "€")
        #expect(info.flagAssetName == "eur")
    }

    @Test func usdcDisplaysAsUSDcWithDollarSymbolAndUSFlag() {
        let info = CurrencyDisplayInfo.info(for: Currency(code: "USDC"))
        #expect(info.displayCode == "USDc")
        #expect(info.currencySymbol == "$")
        #expect(info.flagAssetName == "us")
    }

    @Test(arguments: ["MXN", "ARS", "COP", "BRL"])
    func latinAmericanCurrenciesKeepTheirCodeAndUseALowercaseFlagName(code: String) {
        let info = CurrencyDisplayInfo.info(for: Currency(code: code))
        #expect(info.displayCode == code)
        #expect(info.flagAssetName == code.lowercased())
    }

    @Test func brlUsesRealSymbol() {
        #expect(CurrencyDisplayInfo.info(for: Currency(code: "BRL")).currencySymbol == "R$")
    }

    @Test func unknownCodeFallsBackToRawCodeWithoutSymbolOrFlag() {
        let info = CurrencyDisplayInfo.info(for: Currency(code: "ZZZ"))
        #expect(info.displayCode == "ZZZ")
        #expect(info.subtitle == "")
        #expect(info.currencySymbol == nil)
        #expect(info.flagAssetName == nil)
    }
}
