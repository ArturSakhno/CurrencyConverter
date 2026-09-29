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

    /// Keeps digits and the first locale decimal separator, then regroups the integer part
    /// with the locale's grouping separator (en_US "1234.5" -> "1,234.5") - the same grouping
    /// `AmountDisplayFormatter` uses, so typed and converted amounts look alike. Anything else,
    /// including stale grouping separators, is dropped. Excess fraction digits are truncated,
    /// never rounded. Idempotent, so re-sanitizing the field's own output is a no-op.
    func sanitize(_ raw: String) -> String {
        let plain = ungroupedSanitize(raw)
        let integerDigits = plain.prefix { $0 != decimalSeparator }
        return grouped(String(integerDigits)) + plain.dropFirst(integerDigits.count)
    }

    /// `sanitize` without the grouping step: the canonical digits-and-separator form that
    /// `Decimal(string:locale:)` can parse, since it stops at a grouping separator.
    private func ungroupedSanitize(_ raw: String) -> String {
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

    private func integerDigitCount(of ungrouped: String) -> Int {
        ungrouped.prefix { $0 != decimalSeparator }.count
    }

    /// Groups a run of plain digits the way the locale's number formatter would, including
    /// locales that skip grouping for four-digit values (es_ES "1000", but "10.000").
    private func grouped(_ integerDigits: String) -> String {
        guard integerDigits.count > 3, let value = Decimal(string: integerDigits) else {
            return integerDigits
        }
        return value.formatted(
            .number
                .locale(locale)
                .precision(.fractionLength(0))
                .grouping(.automatic)
        )
    }
}
