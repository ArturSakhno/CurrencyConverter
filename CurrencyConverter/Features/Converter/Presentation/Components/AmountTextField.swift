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
    @Binding var text: String

    @State private var draft = ""
    @State private var availableWidth: CGFloat?
    @State private var naturalWidth: CGFloat = 0

    let sign: String?
    let currencySymbol: String?
    let field: FocusSlot
    let focusedField: FocusState<FocusSlot?>.Binding

    var body: some View {
        HStack(spacing: DS.Spacing.xxs) {
            if let sign {
                Text(sign)
                    .foregroundStyle(draft.isEmpty ? DS.Color.textSecondary : DS.Color.textPrimary)
            }

            HStack(spacing: .zero) {
                if let currencySymbol {
                    Text(currencySymbol)
                        .foregroundStyle(draft.isEmpty ? DS.Color.textSecondary : DS.Color.textPrimary)
                }

                Text(draft.isEmpty ? "0" : draft)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.trailing, DS.Spacing.xxxs)
                    .hidden()
                    .overlay {
                        TextField(
                            text: $draft,
                            prompt: Text(verbatim: "0")
                                .foregroundStyle(DS.Color.textSecondary)
                        ) { EmptyView() }
                            .foregroundStyle(DS.Color.textPrimary)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(2)
                            .focused(focusedField, equals: field)
                    }
            }
        }
        .textStyle(.amountInput)
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

private extension AmountTextField {
    var scale: CGFloat {
        guard let availableWidth, naturalWidth > 0 else { return 1 }
        return min(1, max(DS.minimumAmountScale, availableWidth / naturalWidth))
    }
}

#Preview("Empty") {
    @Previewable @State var text = ""
    @Previewable @FocusState var focusedField: FocusSlot?
    AmountTextField(
        text: $text,
        sign: "−",
        currencySymbol: "$",
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
        field: .bottom,
        focusedField: $focusedField
    )
    .padding()
    .environment(\.dynamicTypeSize, .accessibility5)
}
