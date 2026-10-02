import SwiftUI

@main
struct CurrencyConverterApp: App {
    private let dependencies = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
        }
    }
}
