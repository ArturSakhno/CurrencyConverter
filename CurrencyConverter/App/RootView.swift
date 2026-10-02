import DesignSystem
import SwiftUI

struct RootView: View {
    @State private var coordinator: AppCoordinator

    init(dependencies: DependencyContainer) {
        _coordinator = State(initialValue: AppCoordinator(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack {
            coordinator.makeConverterScreen()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DS.Color.bgPrimary)
                .sheet(item: $coordinator.presentedSheet) { route in
                    coordinator.makeSheet(for: route)
                }
        }
    }
}
