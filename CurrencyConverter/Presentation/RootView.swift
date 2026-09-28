import SwiftUI

struct RootView: View {
    let dependencies: DependencyContainer
    @State private var coordinator = AppCoordinator()
    @State private var selectedQuoteCurrency = CurrencyCatalog.defaultQuote

    var body: some View {
        NavigationStack {
            ConverterView(dependencies: dependencies, coordinator: coordinator, quoteCurrency: selectedQuoteCurrency)
                .sheet(item: $coordinator.presentedSheet) { route in
                    switch route {
                    case .currencyPicker:
                        CurrencyPickerView(
                            coordinator: coordinator,
                            currencies: CurrencyCatalog.availableQuoteCurrencies,
                            selection: $selectedQuoteCurrency
                        )
                    }
                }
        }
    }
}
