import SwiftUI

struct ConverterScreen: View {
    let viewModel: ConverterViewModel
    let onSelectCurrency: () -> Void

    private static let placeholderQuoteCurrency = Currency(code: "XXX")

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                ConverterView(
                    viewModel: viewModel,
                    quoteCurrency: Self.placeholderQuoteCurrency,
                    isPlaceholder: true,
                    onSelectCurrency: onSelectCurrency
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Loading rates"))
            case let .converter(content):
                ConverterView(
                    viewModel: viewModel,
                    quoteCurrency: content.quoteCurrency,
                    isPlaceholder: false,
                    onSelectCurrency: onSelectCurrency
                )
            case .errorScreen:
                ConverterErrorView {
                    Task { await viewModel.retry() }
                }
            case .noConnection:
                NoConnectionView {
                    Task { await viewModel.retry() }
                }
            }
        }
        .task {
            await viewModel.keepRatesUpdated()
        }
    }
}

#Preview {
    ConverterScreen(
        viewModel: DependencyContainer().makeConverterViewModel(),
        onSelectCurrency: {}
    )
}
