@testable import CurrencyConverter
import Foundation
import Testing

struct AmountDisplayFormatterTests {
    private let sut = AmountDisplayFormatter(locale: Locale(identifier: "en_US"))

    @Test func formatsToTwoDecimalPlaces() {
        #expect(sut.string(from: 100, fractionDigits: 2) == "100.00")
    }

    @Test func roundsToTwoDecimalPlaces() throws {
        #expect(try sut.string(from: #require(Decimal(string: "18.415")), fractionDigits: 2) == "18.42")
    }

    @Test func formatsToFourDecimalPlaces() throws {
        #expect(try sut.string(from: #require(Decimal(string: "18.4")), fractionDigits: 4) == "18.4000")
    }

    @Test func groupsThousands() {
        #expect(sut.string(from: 338_724, fractionDigits: 2) == "338,724.00")
    }

    @Test func usesLocaleDecimalSeparator() throws {
        let spanish = AmountDisplayFormatter(locale: Locale(identifier: "es_ES"))
        #expect(try spanish.string(from: #require(Decimal(string: "18.4")), fractionDigits: 2) == "18,40")
    }
}
