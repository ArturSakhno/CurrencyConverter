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
                CurrencyPickerRow(
                    info: .info(for: currency),
                    isSelected: currency == selection,
                    onSelect: { onSelect(currency) }
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.plain)
            .toolbarRole(.browser)
            .toolbar {
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
                    .accessibilityLabel(Text(Localized.Common.close))
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .frame(maxHeight: .infinity)
        .presentationBackground(DS.Color.bgPrimary)
    }
}

#Preview {
    @Previewable @State var selection = CurrencyCatalog.defaultQuote
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
