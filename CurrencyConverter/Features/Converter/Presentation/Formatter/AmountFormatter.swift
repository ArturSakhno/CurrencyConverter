import Foundation

nonisolated struct AmountFormatter: Sendable {
    let locale: Locale
    var maxFractionDigits = 2
    var maxIntegerDigits = 12

    func sanitize(_ raw: String) -> String {
        let plain = ungroupedSanitize(raw)
        let integerDigits = plain.prefix { $0 != decimalSeparator }
        return grouped(String(integerDigits)) + plain.dropFirst(integerDigits.count)
    }

    func sanitizeEdit(from previous: String, to raw: String) -> String {
        let digitCount = integerDigitCount(of: ungroupedSanitize(raw))
        guard digitCount > maxIntegerDigits,
              digitCount > integerDigitCount(of: ungroupedSanitize(previous))
        else {
            return sanitize(raw)
        }
        return sanitize(previous)
    }

    func decimal(from text: String) -> Decimal? {
        let sanitized = ungroupedSanitize(text)
        guard !sanitized.isEmpty else { return nil }
        return Decimal(string: sanitized, locale: locale)
    }

    func string(from value: Decimal, fractionDigits: Int) -> String {
        value.formatted(
            .number
                .locale(locale)
                .precision(.fractionLength(fractionDigits))
                .grouping(.automatic)
        )
    }
}

private extension AmountFormatter {
    nonisolated var decimalSeparator: Character {
        locale.decimalSeparator?.first ?? "."
    }

    nonisolated func ungroupedSanitize(_ raw: String) -> String {
        var integerPart = ""
        var fractionPart = ""
        var hasSeparator = false

        for character in raw {
            if character == decimalSeparator {
                hasSeparator = true
            } else if character.isASCII, character.isNumber {
                if hasSeparator {
                    fractionPart.append(character)
                } else {
                    integerPart.append(character)
                }
            }
        }

        let trimmedLeadingZeros = integerPart.drop { $0 == "0" }
        if trimmedLeadingZeros.isEmpty {
            integerPart = (integerPart.isEmpty && !hasSeparator) ? "" : "0"
        } else {
            integerPart = String(trimmedLeadingZeros)
        }

        guard hasSeparator, maxFractionDigits > 0 else { return integerPart }
        return integerPart + String(decimalSeparator) + String(fractionPart.prefix(maxFractionDigits))
    }

    nonisolated func integerDigitCount(of ungrouped: String) -> Int {
        ungrouped.prefix { $0 != decimalSeparator }.count
    }

    nonisolated func grouped(_ integerDigits: String) -> String {
        guard integerDigits.count > 3, let value = Decimal(string: integerDigits) else {
            return integerDigits
        }
        return string(from: value, fractionDigits: 0)
    }
}
