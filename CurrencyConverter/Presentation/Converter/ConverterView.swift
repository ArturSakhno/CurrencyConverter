import SwiftUI

struct ConverterView: View {
    let dependencies: DependencyContainer
    let coordinator: AppCoordinator

    @State private var status = "Loading…"

    var body: some View {
        VStack(spacing: 16) {
            Text("Converter — full UI lands in roadmap item 6")
            Text(status)
            Button("Open currency picker") {
                coordinator.presentCurrencyPicker()
            }
        }
        .padding()
        .task {
            switch await dependencies.loadRatesUseCase.load() {
            case .loaded(let snapshot, let isFresh):
                status = "Loaded \(snapshot.rates.count) rates (fresh: \(isFresh))"
            case .unavailable:
                status = "Rates unavailable"
            }
        }
    }
}
