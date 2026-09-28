import DesignSystem
import SwiftUI

struct RootView: View {
    let dependencies: DependencyContainer
    @State private var coordinator = AppCoordinator()
    @State private var selectedQuoteCurrency: Currency

    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
        _selectedQuoteCurrency = State(initialValue: dependencies.currencyCatalogUseCase.defaultQuoteCurrency())
    }

    var body: some View {
        NavigationStack {
            ConverterView(dependencies: dependencies, coordinator: coordinator, quoteCurrency: selectedQuoteCurrency)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.bgPrimary)
                .sheet(item: $coordinator.presentedSheet) { route in
                    switch route {
                    case .currencyPicker:
                        CurrencyPickerView(
                            coordinator: coordinator,
                            currencies: dependencies.currencyCatalogUseCase.availableQuoteCurrencies(),
                            selection: $selectedQuoteCurrency
                        )
                    }
                }
        }
        .theme(.standard)
    }
}
