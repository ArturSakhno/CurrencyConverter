import DesignSystem
import SwiftUI

/// Knows nothing about navigation: it reports the pick or the close, and the caller
/// decides what happens next (update state, dismiss the sheet).
struct CurrencyPickerView: View {
    let currencies: [Currency]
    let selection: Currency
    let onSelect: (Currency) -> Void
    let onClose: EmptyClosure

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
                    Text("Choose currency", comment: "Navigation title for the currency picker sheet")
                        .textStyle(\.h4)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) {
                        DS.Icon.cross
                            .resizable()
                            .frame(width: DS.Size.closeButton, height: DS.Size.closeButton)
                    }
                    .accessibilityLabel(Text("Close", comment: "Accessibility label for the currency picker's close button"))
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .frame(maxHeight: .infinity)
        .presentationBackground(.bgPrimary)
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
