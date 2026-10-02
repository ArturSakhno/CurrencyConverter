import DesignSystem
import SwiftUI

nonisolated enum FocusSlot: Hashable {
    case top
    case bottom
}

struct AmountTextField: View {
    @Binding var text: String

    @State private var draft = ""

    let sign: String?
    let currencySymbol: String?
    let field: FocusSlot
    let focusedField: FocusState<FocusSlot?>.Binding

    var body: some View {
        HStack(spacing: DS.Spacing.xxs) {
            if let sign {
                Text(sign)
                    .foregroundStyle(prefixColor)
            }

            HStack(spacing: .zero) {
                if let currencySymbol {
                    Text(currencySymbol)
                        .foregroundStyle(prefixColor)
                }

                input
            }
        }
        .textStyle(.amountInput)
        .monospacedDigit()
        .shrinkToFit(minimumScale: DS.minimumAmountScale)
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
    var prefixColor: Color {
        draft.isEmpty ? DS.Color.textSecondary : DS.Color.textPrimary
    }

    var input: some View {
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
    .padding(DS.Spacing.m)
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
    .padding(DS.Spacing.m)
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
    .padding(DS.Spacing.m)
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
    .padding(DS.Spacing.m)
    .environment(\.dynamicTypeSize, .accessibility5)
}
