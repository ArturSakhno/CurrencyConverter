import Foundation

/// Normalizes raw keyboard input into a valid, parseable amount string.
nonisolated struct AmountInputSanitizer: Sendable {
    let locale: Locale
    var maxFractionDigits = 2
    var maxIntegerDigits = 12

    private var decimalSeparator: Character {
        locale.decimalSeparator?.first ?? "."
    }

    /// Keeps digits and the first locale decimal separator; anything else (including
    /// grouping separators from a previously formatted value) is dropped. Excess digits
    /// are truncated, never rounded.
    nonisolated func sanitize(_ raw: String) -> String {
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
            integerPart = String(trimmedLeadingZeros.prefix(maxIntegerDigits))
        }

        guard hasSeparator, maxFractionDigits > 0 else { return integerPart }
        return integerPart + String(decimalSeparator) + String(fractionPart.prefix(maxFractionDigits))
    }

    nonisolated func decimal(from text: String) -> Decimal? {
        let sanitized = sanitize(text)
        guard !sanitized.isEmpty else { return nil }
        return Decimal(string: sanitized, locale: locale)
    }
}
