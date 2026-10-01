@testable import CurrencyConverter
import Foundation
import Networking
import Testing

struct DefaultTickersAPIClientTests {
    @Test func requestsTickersWithCommaJoinedCodesAndDecodesNullEntries() async throws {
        let networkClient = RecordingNetworkClient(response: Data("""
        [
            {"ask": "18.4105000000", "bid": "18.4069700000", "book": "usdc_mxn", "date": "2025-10-20T20:14:57.361483956"},
            null
        ]
        """.utf8))
        let sut = DefaultTickersAPIClient(networkClient: networkClient)

        let tickers = try await sut.fetchTickers(quoteCurrencyCodes: ["MXN", "EUR"])

        let request = await networkClient.lastRequest
        #expect(request?.httpMethod == "GET")
        #expect(request?.url?.absoluteString == "https://api.dolarapp.dev/v1/tickers?currencies=MXN,EUR")
        #expect(tickers.count == 2)
        #expect(tickers[0]?.book == "usdc_mxn")
        #expect(tickers[1] == nil)
    }

    @Test func propagatesNetworkErrors() async {
        let sut = DefaultTickersAPIClient(networkClient: FailingNetworkClient())

        await #expect(throws: NetworkError.self) {
            try await sut.fetchTickers(quoteCurrencyCodes: ["MXN"])
        }
    }
}

private actor RecordingNetworkClient: NetworkClient {
    private(set) var lastRequest: URLRequest?

    private let response: Data

    init(response: Data) {
        self.response = response
    }

    func send(_ request: URLRequest) async throws(NetworkError) -> Data {
        lastRequest = request
        return response
    }
}

private struct FailingNetworkClient: NetworkClient {
    func send(_: URLRequest) async throws(NetworkError) -> Data {
        throw .transport(URLError(.notConnectedToInternet))
    }
}
