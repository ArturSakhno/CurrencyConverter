import Foundation
import Networking

nonisolated protocol TickersAPIClient: Sendable {
    func fetchTickers(quoteCurrencyCodes: [String]) async throws(NetworkError) -> [TickerDTO?]
}

nonisolated struct DefaultTickersAPIClient: TickersAPIClient {
    private static let baseURL = URL(string: "https://api.dolarapp.dev")!

    private let networkClient: NetworkClient

    nonisolated init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    nonisolated func fetchTickers(quoteCurrencyCodes: [String]) async throws(NetworkError) -> [TickerDTO?] {
        let request = try RequestBuilder(baseURL: Self.baseURL)
            .path("v1/tickers")
            .query("currencies", quoteCurrencyCodes.joined(separator: ","))
            .build()
        return try await networkClient.send(request, decoding: [TickerDTO?].self)
    }
}
