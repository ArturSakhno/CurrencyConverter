import DesignSystem
import SwiftUI

struct RootView: View {
    private let currencyCatalog: CurrencyCatalogUseCase
    @State private var coordinator = AppCoordinator()
    @State private var converterViewModel: ConverterViewModel

    init(dependencies: DependencyContainer) {
        currencyCatalog = dependencies.currencyCatalogUseCase
        _converterViewModel = State(initialValue: dependencies.makeConverterViewModel())
    }

    var body: some View {
        NavigationStack {
            ConverterView(
                viewModel: converterViewModel,
                baseCurrency: currencyCatalog.baseCurrency(),
                onSelectCurrency: { coordinator.presentCurrencyPicker() }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bgPrimary)
            .sheet(item: $coordinator.presentedSheet) { route in
                switch route {
                case .currencyPicker:
                    CurrencyPickerView(
                        currencies: currencyCatalog.availableQuoteCurrencies(),
                        selection: converterViewModel.quoteCurrency,
                        onSelect: { currency in
                            converterViewModel.selectQuoteCurrency(currency)
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
