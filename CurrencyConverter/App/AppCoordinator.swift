import Observation
import SwiftUI

@Observable
final class AppCoordinator {
    enum SheetRoute: Identifiable {
        case currencyPicker

        var id: Self { self }
    }

    var presentedSheet: SheetRoute?

    private let converterViewModel: ConverterViewModel

    init(dependencies: DependencyContainer) {
        converterViewModel = dependencies.makeConverterViewModel()
    }

    func makeConverterScreen() -> some View {
        ConverterScreen(
            viewModel: converterViewModel,
            onSelectCurrency: { [weak self] in self?.presentCurrencyPicker() }
        )
    }

    @ViewBuilder
    func makeSheet(for route: SheetRoute) -> some View {
        switch route {
        case .currencyPicker:
            if case let .converter(content) = converterViewModel.state {
                CurrencyPickerView(
                    currencies: content.availableCurrencies,
                    selection: content.quoteCurrency,
                    onSelect: { [weak self] currency in
                        self?.converterViewModel.selectQuoteCurrency(currency)
                        self?.dismissSheet()
                    },
                    onClose: { [weak self] in self?.dismissSheet() }
                )
            }
        }
    }
}

private extension AppCoordinator {
    func presentCurrencyPicker() {
        presentedSheet = .currencyPicker
    }

    func dismissSheet() {
        presentedSheet = nil
    }
}
