import Foundation

nonisolated protocol TickersAPIClient: Sendable {
    /// Throws `APIError.noUsableRates` when no ticker in the response is usable.
    func fetchTickers(base: Currency, quotes: [Currency]) async throws -> [ExchangeRate]
}

struct URLSessionTickersAPIClient: TickersAPIClient {
    private let session: URLSession
    private static let endpoint = URL(string: "https://api.dolarapp.dev/v1/tickers")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchTickers(base: Currency, quotes: [Currency]) async throws -> [ExchangeRate] {
        var components = URLComponents(url: Self.endpoint, resolvingAgainstBaseURL: false)!
        // No space in the separator: a space in the currency list 500s the whole batch.
        components.queryItems = [URLQueryItem(name: "currencies", value: quotes.map(\.code).joined(separator: ","))]

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: components.url!)
        } catch {
            throw APIError.transport("\(error)")
        }

        return try Self.rates(from: data, response: response, base: base, quotes: quotes)
    }

    /// Turns a `/v1/tickers` response into rates. Null elements and tickers that fail
    /// `TickerDTO.toDomain(base:quotes:)` are dropped one by one, and a repeated quote keeps its
    /// first ticker. Whatever is left is returned, even if some requested currencies are
    /// missing; an empty result throws instead, so it can't replace the cached snapshot.
    nonisolated static func rates(
        from data: Data,
        response: URLResponse,
        base: Currency,
        quotes: [Currency]
    ) throws -> [ExchangeRate] {
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

        var seen = Set<Currency>()
        let rates = dtos
            .compactMap { $0?.toDomain(base: base, quotes: quotes) }
            .filter { seen.insert($0.quoteCurrency).inserted }
        guard !rates.isEmpty else {
            throw APIError.noUsableRates(correlationID: correlationID)
        }
        return rates
    }
}
