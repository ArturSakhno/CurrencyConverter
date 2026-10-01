import SwiftUI

struct ConverterScreen: View {
    private static let placeholderQuoteCurrency = Currency(code: "XXX")

    let viewModel: ConverterViewModel
    let onSelectCurrency: () -> Void

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
                .accessibilityLabel(Text(Localized.Converter.loadingRates))
            case let .converter(content):
                ConverterView(
                    viewModel: viewModel,
                    quoteCurrency: content.quoteCurrency,
                    isPlaceholder: false,
                    onSelectCurrency: onSelectCurrency
                )
            case .failed(.unavailable):
                StatusScreenView(
                    systemImage: "exclamationmark.triangle",
                    title: Localized.Converter.unavailableTitle,
                    message: Localized.Converter.unavailableMessage,
                    isRetrying: viewModel.isRetrying
                ) {
                    viewModel.onRetry()
                }
            case .failed(.noConnection):
                StatusScreenView(
                    systemImage: "wifi.slash",
                    title: Localized.Converter.noConnectionTitle,
                    message: Localized.Converter.noConnectionMessage,
                    isRetrying: viewModel.isRetrying
                ) {
                    viewModel.onRetry()
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
