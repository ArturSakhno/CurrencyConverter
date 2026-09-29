import DesignSystem
import SwiftUI

/// Identifies an amount field by the *currency* it holds (base vs. quote), not by its
/// on-screen top/bottom slot. Row position is swap-controlled and independent of this.
/// Used for conversion-direction logic (which use-case math to apply), never for focus -
/// see `FocusSlot`.
nonisolated enum AmountField: Hashable {
    case base
    case quote
}

/// Identifies an amount field by its on-screen slot (top vs. bottom), the opposite of
/// `AmountField`. `.focused(_:equals:)` claims must stay slot-stable: reassigning which
/// *currency* a slot's `equals:` value represents on every swap (rather than which slot)
/// does not reliably carry focus across the swap in practice, so the actual FocusState is
/// keyed by slot, and the caller derives which currency is focused from slot + `isBaseOnTop`.
nonisolated enum FocusSlot: Hashable {
    case top
    case bottom
}

/// Amount entry on the native decimal pad. Focus is applied by the caller via
/// `.focused(_:equals:)`, so the component stays independent of any ViewModel field enum.
///
/// Fills the width it's offered (trailing-aligned) and shrinks, down to `minimumScale`,
/// when the amount wouldn't fit at full size. Below that floor it overflows.
struct AmountTextField: View {
    /// Smallest scale the amount shrinks to before it's allowed to overflow.
    static let minimumScale: CGFloat = 0.6

    @Binding var text: String
    let sign: String?
    /// Currency symbol shown glued to the number ("$100"); display-only, never part of `text`.
    var currencySymbol: String?
    let accessibilityLabel: LocalizedStringKey
    let field: FocusSlot
    var focusedField: FocusState<FocusSlot?>.Binding
    var sanitizer = AmountInputSanitizer(locale: .current)

    @State private var availableWidth: CGFloat?
    @State private var naturalWidth: CGFloat = 0

    private var scale: CGFloat {
        guard let availableWidth, naturalWidth > 0 else { return 1 }
        return min(1, max(Self.minimumScale, availableWidth / naturalWidth))
    }

    var body: some View {
        HStack(spacing: 4) {
            if let sign {
                Text(sign)
                    .foregroundStyle(text.isEmpty ? .textSecondary : .textPrimary)
                    .accessibilityHidden(true)
            }

            HStack(spacing: .zero) {
                if let currencySymbol {
                    Text(currencySymbol)
                        .foregroundStyle(text.isEmpty ? .textSecondary : .textPrimary)
                        .accessibilityHidden(true)
                }

                // Width comes from a hidden Text mirroring the current value, so the prefixes stay
                // attached to the number. Relying on the TextField's own intrinsic width doesn't
                // work: UIKit doesn't re-measure it after edit-menu actions like Cut.
                Text(text.isEmpty ? "0" : text)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.trailing, 2) // room for the caret
                    .hidden()
                    .overlay {
                        TextField(text: $text, prompt: Text(verbatim: "0").foregroundStyle(.textSecondary)) {
                            Text(accessibilityLabel)
                        }
                        .foregroundStyle(.textPrimary)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                        .accessibilityLabel(accessibilityLabel)
                        .focused(focusedField, equals: field)
                    }
            }
        }
        .textStyle(\.amountInput)
        .monospacedDigit()
        .fixedSize()
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
            naturalWidth = width
        }
        // Shrinks visually rather than via a smaller font: the focused UITextField ignores
        // font changes while editing, so its text would outgrow the hidden Text's width and
        // scroll. Layout keeps the full-size height, so the row doesn't jump as it shrinks.
        .scaleEffect(scale, anchor: .trailing)
        // `minWidth: 0` so the frame reports the width it's offered rather than growing to
        // the fixed-size content - otherwise the measured space tracks the content.
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
            availableWidth = width
        }
        .onChange(of: text) { oldValue, newValue in
            // Only the user's own typing is sanitized. The unfocused field receives an
            // already-formatted converted amount, which may legitimately exceed the entry cap.
            guard focusedField.wrappedValue == field else { return }
            let sanitized = sanitizer.sanitizeEdit(from: oldValue, to: newValue)
            if sanitized != newValue {
                text = sanitized
            }
        }
    }
}

#Preview("Empty") {
    @Previewable @State var text = ""
    @Previewable @FocusState var focusedField: FocusSlot?
    AmountTextField(
        text: $text,
        sign: "−",
        currencySymbol: "$",
        accessibilityLabel: "Amount in USDc",
        field: .top,
        focusedField: $focusedField
    )
        .padding()
}

#Preview("Filled") {
    @Previewable @State var text = "1841.12"
    @Previewable @FocusState var focusedField: FocusSlot?
    AmountTextField(
        text: $text,
        sign: "+",
        currencySymbol: "$",
        accessibilityLabel: "Amount in MXN",
        field: .bottom,
        focusedField: $focusedField
    )
        .padding()
}

#Preview("Dark Mode") {
    @Previewable @State var text = "100"
    @Previewable @FocusState var focusedField: FocusSlot?
    AmountTextField(
        text: $text,
        sign: "−",
        currencySymbol: "$",
        accessibilityLabel: "Amount in USDc",
        field: .top,
        focusedField: $focusedField
    )
        .padding()
        .preferredColorScheme(.dark)
}

#Preview("Accessibility XXXL") {
    @Previewable @State var text = "338724.99"
    @Previewable @FocusState var focusedField: FocusSlot?
    AmountTextField(
        text: $text,
        sign: "+",
        currencySymbol: "$",
        accessibilityLabel: "Amount in COP",
        field: .bottom,
        focusedField: $focusedField
    )
        .padding()
        .environment(\.dynamicTypeSize, .accessibility5)
}
