import Observation

@Observable
final class AppCoordinator {
    enum SheetRoute: Identifiable {
        case currencyPicker
        var id: Self { self }
    }

    var presentedSheet: SheetRoute?

    func presentCurrencyPicker() {
        presentedSheet = .currencyPicker
    }

    func dismissSheet() {
        presentedSheet = nil
    }
}
