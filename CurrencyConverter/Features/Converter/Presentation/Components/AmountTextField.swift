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

    private let prompt = "0"
    private let inputLineLimit = 2

    var body: some View {
        HStack(spacing: DS.Spacing.xxs) {
            if let sign {
                Text(sign)
                    .foregroundStyle(prefixColor)
            }

            HStack(spacing: DS.Spacing.zero) {
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

    private var input: some View {
        Text(draft.isEmpty ? prompt : draft)
            .lineLimit(1)
            .fixedSize()
            .padding(.trailing, DS.Spacing.xxxs)
            .hidden()
            .overlay {
                TextField(
                    "",
                    text: $draft,
                    prompt: Text(verbatim: prompt)
                        .foregroundStyle(DS.Color.textSecondary)
                )
                .foregroundStyle(DS.Color.textPrimary)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .lineLimit(inputLineLimit)
                .focused(focusedField, equals: field)
            }
    }

    private var prefixColor: Color {
        draft.isEmpty ? DS.Color.textSecondary : DS.Color.textPrimary
    }
}

#if DEBUG
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
#endif
