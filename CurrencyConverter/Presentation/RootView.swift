import SwiftUI

struct RootView: View {
    let dependencies: DependencyContainer
    @State private var coordinator = AppCoordinator()

    var body: some View {
        NavigationStack {
            ConverterView(dependencies: dependencies, coordinator: coordinator)
                .sheet(item: $coordinator.presentedSheet) { route in
                    switch route {
                    case .currencyPicker:
                        CurrencyPickerView(coordinator: coordinator)
                    }
                }
        }
    }
}
