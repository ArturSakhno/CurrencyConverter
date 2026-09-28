import SwiftUI

struct CurrencyPickerView: View {
    let coordinator: AppCoordinator
    let currencies: [Currency]
    @Binding var selection: Currency

    var body: some View {
        NavigationStack {
            List(currencies) { currency in
                CurrencyPickerRow(
                    info: .info(for: currency),
                    isSelected: currency == selection,
                    onSelect: { select(currency) }
                )

                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .navigationTitle(Text("Choose currency", comment: "Navigation title for the currency picker sheet"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        coordinator.dismissSheet()
                    } label: {
                        Image(.cross)
                            .resizable()
                            .frame(width: 32, height: 32)
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

    private func select(_ currency: Currency) {
        selection = currency
        coordinator.dismissSheet()
    }
}

#Preview {
    @Previewable @State var selection = CurrencyCatalog.defaultQuote
    Color.clear
        .sheet(isPresented: .constant(true)) {
            CurrencyPickerView(
                coordinator: .init(),
                currencies: CurrencyCatalog.availableQuoteCurrencies,
                selection: $selection
            )
        }
}
