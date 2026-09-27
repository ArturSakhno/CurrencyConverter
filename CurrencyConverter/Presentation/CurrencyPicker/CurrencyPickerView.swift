import SwiftUI

struct CurrencyPickerView: View {
    let coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("Currency picker — full UI lands in roadmap item 7")
            Button("Close") {
                coordinator.dismissSheet()
            }
        }
        .padding()
    }
}
