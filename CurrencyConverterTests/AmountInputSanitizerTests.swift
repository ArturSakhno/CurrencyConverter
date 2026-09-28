import Foundation
import Testing
@testable import CurrencyConverter

struct AmountInputSanitizerTests {
    private let sut = AmountInputSanitizer(locale: Locale(identifier: "en_US"))

    @Test(arguments: [
        ("12a3", "123"),
        ("1 2", "12"),
        ("1.2.3", "1.23"),
        ("..", "0."),
        ("", ""),
    ])
    func stripsInvalidCharactersAndExtraSeparators(input: String, expected: String) {
        #expect(sut.sanitize(input) == expected)
    }

    @Test func truncatesFractionBeyondTwoDigitsWithoutRounding() {
        #expect(sut.sanitize("1.239") == "1.23")
    }

    @Test(arguments: [
        (".5", "0.5"),
        ("00", "0"),
        ("007", "7"),
        ("0.05", "0.05"),
        ("0", "0"),
    ])
    func normalizesLeadingZeros(input: String, expected: String) {
        #expect(sut.sanitize(input) == expected)
    }

    @Test func regroupsExistingGroupingSeparators() {
        #expect(sut.sanitize("1,234.5") == "1,234.5")
    }

    @Test func capsIntegerDigits() {
        #expect(sut.sanitize("1234567890123456") == "123,456,789,012")
    }

    @Test(arguments: [
        ("1000", "1,000"),
        ("10000", "10,000"),
        ("100000", "100,000"),
        ("1000000", "1,000,000"),
    ])
    func groupsIntegerPartEveryThreeDigits(input: String, expected: String) {
        #expect(sut.sanitize(input) == expected)
    }

    @Test func usesLocaleDecimalSeparator() {
        let spanish = AmountInputSanitizer(locale: Locale(identifier: "es_ES"))
        #expect(spanish.sanitize("12,5") == "12,5")
        #expect(spanish.decimal(from: "12,5") == Decimal(string: "12.5"))
    }

    @Test func emptyInputParsesToNil() {
        #expect(sut.decimal(from: "") == nil)
    }

    @Test func parsesWithoutDoublePrecisionDrift() {
        #expect(sut.decimal(from: "0.1") == Decimal(string: "0.1"))
    }

    @Test func parsesGroupedIntegerToCorrectDecimal() {
        #expect(sut.decimal(from: "10000") == Decimal(string: "10000"))
    }
}
