import Foundation

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
