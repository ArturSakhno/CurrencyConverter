import Foundation

/// Formats a `Decimal` money value to a fixed number of fraction digits for display.
/// Kept separate from `AmountInputSanitizer` (which normalizes raw keyboard text) since this
/// is the opposite direction: value -> display string, used for both the derived amount field
/// (2 decimals, every currency) and the rate pill (4 decimals).
nonisolated struct AmountDisplayFormatter: Sendable {
    let locale: Locale

    func string(from value: Decimal, fractionDigits: Int) -> String {
        value.formatted(
            .number
                .locale(locale)
                .precision(.fractionLength(fractionDigits))
                .grouping(.automatic)
        )
    }
}
