import Foundation
import SwiftUI

struct ConverterScreen: View {
    private static let placeholderQuoteCurrency = Currency(code: "XXX")

    let viewModel: ConverterViewModel
    let onSelectCurrency: () -> Void

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                converter(quoteCurrency: Self.placeholderQuoteCurrency, isPlaceholder: true)
            case let .converter(content):
                converter(quoteCurrency: content.quoteCurrency, isPlaceholder: false)
            case .failed(.unavailable):
                failure(.unavailable)
            case .failed(.noConnection):
                failure(.noConnection)
            }
        }
        .task {
            await viewModel.keepRatesUpdated()
        }
    }
}

private extension ConverterScreen {
    func converter(quoteCurrency: Currency, isPlaceholder: Bool) -> some View {
        ConverterView(
            viewModel: viewModel,
            quoteCurrency: quoteCurrency,
            isPlaceholder: isPlaceholder,
            onSelectCurrency: onSelectCurrency
        )
    }

    func failure(_ error: ConverterViewModel.LoadError) -> some View {
        StatusScreenView(
            systemImage: error.systemImage,
            title: error.title,
            message: error.message,
            isRetrying: viewModel.isRetrying
        ) {
            viewModel.onRetry()
        }
    }
}

private extension ConverterViewModel.LoadError {
    var systemImage: String {
        switch self {
        case .noConnection: "wifi.slash"
        case .unavailable: "exclamationmark.triangle"
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .noConnection: Localized.Converter.noConnectionTitle
        case .unavailable: Localized.Converter.unavailableTitle
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .noConnection: Localized.Converter.noConnectionMessage
        case .unavailable: Localized.Converter.unavailableMessage
        }
    }
}

#Preview {
    ConverterScreen(
        viewModel: DependencyContainer().makeConverterViewModel(),
        onSelectCurrency: {}
    )
}
