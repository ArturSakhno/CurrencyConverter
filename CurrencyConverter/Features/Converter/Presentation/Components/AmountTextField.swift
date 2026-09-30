import DesignSystem
import SwiftUI

nonisolated enum AmountField: Hashable {
    case base
    case quote
}

nonisolated enum FocusSlot: Hashable {
    case top
    case bottom
}

struct AmountTextField: View {
    static let minimumScale: CGFloat = 0.1

    @Binding var text: String
    let sign: String?
    var currencySymbol: String?
    let accessibilityLabel: LocalizedStringKey
    let field: FocusSlot
    var focusedField: FocusState<FocusSlot?>.Binding

    @State private var draft = ""
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
                    .foregroundStyle(draft.isEmpty ? .textSecondary : .textPrimary)
                    .accessibilityHidden(true)
            }

            HStack(spacing: .zero) {
                if let currencySymbol {
                    Text(currencySymbol)
                        .foregroundStyle(draft.isEmpty ? .textSecondary : .textPrimary)
                        .accessibilityHidden(true)
                }

                Text(draft.isEmpty ? "0" : draft)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.trailing, 2)
                    .hidden()
                    .overlay {
                        TextField(text: $draft, prompt: Text(verbatim: "0").foregroundStyle(.textSecondary)) {
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
        .scaleEffect(scale, anchor: .trailing)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
            availableWidth = width
        }
        .onChange(of: text, initial: true) {
            draft = text
        }
        .onChange(of: draft) {
            guard draft != text else { return }
            text = draft
            draft = text
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
