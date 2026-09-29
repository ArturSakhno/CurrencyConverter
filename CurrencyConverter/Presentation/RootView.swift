import DesignSystem
import SwiftUI

struct RootView: View {
    private let currencyCatalog: CurrencyCatalogUseCase
    @State private var coordinator = AppCoordinator()
    @State private var converterViewModel: ConverterViewModel
    @State private var selectedQuoteCurrency: Currency

    init(dependencies: DependencyContainer) {
        currencyCatalog = dependencies.currencyCatalogUseCase
        _converterViewModel = State(initialValue: dependencies.makeConverterViewModel())
        _selectedQuoteCurrency = State(initialValue: dependencies.currencyCatalogUseCase.defaultQuoteCurrency())
    }

    var body: some View {
        NavigationStack {
            ConverterView(
                viewModel: converterViewModel,
                baseCurrency: currencyCatalog.baseCurrency(),
                quoteCurrency: selectedQuoteCurrency,
                onSelectCurrency: { coordinator.presentCurrencyPicker() }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bgPrimary)
            .sheet(item: $coordinator.presentedSheet) { route in
                switch route {
                case .currencyPicker:
                    CurrencyPickerView(
                        currencies: currencyCatalog.availableQuoteCurrencies(),
                        selection: selectedQuoteCurrency,
                        onSelect: { currency in
                            selectedQuoteCurrency = currency
                            coordinator.dismissSheet()
                        },
                        onClose: { coordinator.dismissSheet() }
                    )
                }
            }
        }
        .theme(.standard)
    }
}
