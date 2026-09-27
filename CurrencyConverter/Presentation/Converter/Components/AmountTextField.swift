import SwiftUI

/// Amount entry on the native decimal pad. Focus is applied by the caller via
/// `.focused(_:equals:)`, so the component stays independent of any ViewModel field enum.
struct AmountTextField: View {
    @Binding var text: String
    let sign: String?
    /// Currency symbol shown glued to the number ("$100"); display-only, never part of `text`.
    var currencySymbol: String? = nil
    let accessibilityLabel: LocalizedStringKey
    var sanitizer = AmountInputSanitizer(locale: .current)

    @ScaledMetric(relativeTo: .largeTitle) private var fontSize: CGFloat = 32

    var body: some View {
        HStack(spacing: 4) {
            if let sign {
                Text(sign)
                    .foregroundStyle(text.isEmpty ? .secondary : .primary)
                    .accessibilityHidden(true)
            }

            HStack(spacing: .zero) {
                if let currencySymbol {
                    Text(currencySymbol)
                        .foregroundStyle(text.isEmpty ? .secondary : .primary)
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
                        TextField(text: $text, prompt: Text("0").foregroundStyle(.secondary)) {
                            Text(accessibilityLabel)
                        }
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .accessibilityLabel(accessibilityLabel)
                    }
            }
        }
        .font(.system(size: fontSize))
        .monospacedDigit()
        .onChange(of: text) { _, newValue in
            let sanitized = sanitizer.sanitize(newValue)
            if sanitized != newValue {
                text = sanitized
            }
        }
    }
}

#Preview("Empty") {
    @Previewable @State var text = ""
    AmountTextField(text: $text, sign: "−", currencySymbol: "$", accessibilityLabel: "Amount in USDc")
        .padding()
}

#Preview("Filled") {
    @Previewable @State var text = "1841.12"
    AmountTextField(text: $text, sign: "+", currencySymbol: "$", accessibilityLabel: "Amount in MXN")
        .padding()
}

#Preview("Dark Mode") {
    @Previewable @State var text = "100"
    AmountTextField(text: $text, sign: "−", currencySymbol: "$", accessibilityLabel: "Amount in USDc")
        .padding()
        .preferredColorScheme(.dark)
}

#Preview("Accessibility XXXL") {
    @Previewable @State var text = "338724.99"
    AmountTextField(text: $text, sign: "+", currencySymbol: "$", accessibilityLabel: "Amount in COP")
        .padding()
        .environment(\.dynamicTypeSize, .accessibility5)
}
