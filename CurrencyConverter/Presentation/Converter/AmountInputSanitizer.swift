import Foundation

/// Normalizes raw keyboard input into a valid, parseable amount string.
nonisolated struct AmountInputSanitizer: Sendable {
    let locale: Locale
    var maxFractionDigits = 2
    /// Entry limit only, enforced by `sanitizeEdit(from:to:)`. `sanitize` never drops integer
    /// digits: a converted amount can legitimately exceed this (e.g. USDc -> COP), and
    /// truncating it would silently change the value.
    var maxIntegerDigits = 12

    private var decimalSeparator: Character {
        locale.decimalSeparator?.first ?? "."
    }

    /// Keeps digits and the first locale decimal separator; anything else (including
    /// grouping separators from a previously formatted value) is dropped. Excess fraction
    /// digits are truncated, never rounded.
    func sanitize(_ raw: String) -> String {
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

    /// Sanitizes a keyboard edit, rejecting it - returning the sanitized `previous` - when it
    /// would grow the integer part past `maxIntegerDigits`. A value already over the cap
    /// (a converted amount the user then edits) can still shrink.
    func sanitizeEdit(from previous: String, to raw: String) -> String {
        let sanitized = sanitize(raw)
        let sanitizedPrevious = sanitize(previous)
        let digitCount = integerDigitCount(of: sanitized)
        guard digitCount > maxIntegerDigits,
              digitCount > integerDigitCount(of: sanitizedPrevious) else {
            return sanitized
        }
        return sanitizedPrevious
    }

    func decimal(from text: String) -> Decimal? {
        let sanitized = sanitize(text)
        guard !sanitized.isEmpty else { return nil }
        return Decimal(string: sanitized, locale: locale)
    }

    private func integerDigitCount(of sanitized: String) -> Int {
        sanitized.prefix { $0 != decimalSeparator }.count
    }
}
