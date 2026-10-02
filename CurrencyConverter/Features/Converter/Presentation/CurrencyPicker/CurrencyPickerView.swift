import DesignSystem
import SwiftUI

struct CurrencyPickerView: View {
    let currencies: [Currency]
    let selection: Currency
    let onSelect: (Currency) -> Void
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            List(currencies) { currency in
                row(for: currency)
            }
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.plain)
            .toolbarRole(.browser)
            .toolbar {
                toolbarContent
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .frame(maxHeight: .infinity)
        .presentationBackground(DS.Color.bgPrimary)
    }
}

private extension CurrencyPickerView {
    @ToolbarContentBuilder var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(Localized.Converter.chooseCurrency)
                .textStyle(.h4)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: onClose) {
                DS.Icon.cross
                    .resizable()
                    .frame(width: DS.Size.closeButton, height: DS.Size.closeButton)
            }
        }
    }

    func row(for currency: Currency) -> some View {
        CurrencyPickerRow(
            info: .info(for: currency),
            isSelected: currency == selection,
            onSelect: { onSelect(currency) }
        )
        .listRowInsets(
            .init(
                top: DS.Spacing.s,
                leading: DS.Spacing.m,
                bottom: DS.Spacing.s,
                trailing: DS.Spacing.m
            )
        )
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    @Previewable @State var selection = CurrencyCatalog.availableQuoteCurrencies[0]
    Color.clear
        .sheet(isPresented: .constant(true)) {
            CurrencyPickerView(
                currencies: CurrencyCatalog.availableQuoteCurrencies,
                selection: selection,
                onSelect: { selection = $0 },
                onClose: {}
            )
        }
}
