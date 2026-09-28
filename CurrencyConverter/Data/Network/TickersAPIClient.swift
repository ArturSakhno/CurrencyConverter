import Foundation

nonisolated protocol TickersAPIClient: Sendable {
    func fetchTickers(quoteCurrencyCodes: [String]) async throws -> [ExchangeRate]
}

 struct URLSessionTickersAPIClient: TickersAPIClient {
    private let session: URLSession
    private static let endpoint = URL(string: "https://api.dolarapp.dev/v1/tickers")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchTickers(quoteCurrencyCodes: [String]) async throws -> [ExchangeRate] {
        var components = URLComponents(url: Self.endpoint, resolvingAgainstBaseURL: false)!
        // No space in the separator: a space in the currency list 500s the whole batch.
        components.queryItems = [URLQueryItem(name: "currencies", value: quoteCurrencyCodes.joined(separator: ","))]

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: components.url!)
        } catch {
            throw APIError.transport("\(error)")
        }

        let correlationID = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "x-correlation-id")
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.unexpectedStatus(status, correlationID: correlationID)
        }

        let dtos: [TickerDTO?]
        do {
            dtos = try JSONDecoder().decode([TickerDTO?].self, from: data)
        } catch {
            throw APIError.decoding("\(error)", correlationID: correlationID)
        }

        return dtos.compactMap { $0?.toDomain() }
    }
}
