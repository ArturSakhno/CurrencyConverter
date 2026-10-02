import DesignSystem
import SwiftUI

struct RootView: View {
    @State private var coordinator = AppCoordinator()
    @State private var converterViewModel: ConverterViewModel

    init(dependencies: DependencyContainer) {
        _converterViewModel = State(initialValue: dependencies.makeConverterViewModel())
    }

    var body: some View {
        NavigationStack {
            ConverterScreen(
                viewModel: converterViewModel,
                onSelectCurrency: { coordinator.presentCurrencyPicker() }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DS.Color.bgPrimary)
            .sheet(item: $coordinator.presentedSheet) { route in
                sheetContent(for: route)
            }
        }
    }
}

private extension RootView {
    @ViewBuilder
    func sheetContent(for route: AppCoordinator.SheetRoute) -> some View {
        switch route {
        case .currencyPicker:
            if case let .converter(content) = converterViewModel.state {
                CurrencyPickerView(
                    currencies: content.availableCurrencies,
                    selection: content.quoteCurrency,
                    onSelect: { currency in
                        converterViewModel.selectQuoteCurrency(currency)
                        coordinator.dismissSheet()
                    },
                    onClose: { coordinator.dismissSheet() }
                )
            }
        }
    }
}
