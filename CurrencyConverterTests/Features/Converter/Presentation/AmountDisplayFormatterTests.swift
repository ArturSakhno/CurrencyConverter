import Foundation
import Testing
@testable import CurrencyConverter

struct AmountDisplayFormatterTests {
    private let sut = AmountDisplayFormatter(locale: Locale(identifier: "en_US"))

    @Test func formatsToTwoDecimalPlaces() {
        #expect(sut.string(from: 100, fractionDigits: 2) == "100.00")
    }

    @Test func roundsToTwoDecimalPlaces() {
        #expect(sut.string(from: Decimal(string: "18.415")!, fractionDigits: 2) == "18.42")
    }

    @Test func formatsToFourDecimalPlaces() {
        #expect(sut.string(from: Decimal(string: "18.4")!, fractionDigits: 4) == "18.4000")
    }

    @Test func groupsThousands() {
        #expect(sut.string(from: 338724, fractionDigits: 2) == "338,724.00")
    }

    @Test func usesLocaleDecimalSeparator() {
        let spanish = AmountDisplayFormatter(locale: Locale(identifier: "es_ES"))
        #expect(spanish.string(from: Decimal(string: "18.4")!, fractionDigits: 2) == "18,40")
    }
}
