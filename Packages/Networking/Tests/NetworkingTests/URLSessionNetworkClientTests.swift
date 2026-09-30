import Foundation
import Networking
import Testing

@Suite(.serialized)
struct URLSessionNetworkClientTests {
    private let request = URLRequest(url: URL(string: "https://api.example.com/v1/items")!)
    private let sut: URLSessionNetworkClient

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        sut = URLSessionNetworkClient(session: URLSession(configuration: configuration))
    }

    @Test func returnsBodyForStatus200() async throws {
        StubURLProtocol.stub = .init(statusCode: 200, body: Data("hello".utf8))

        let data = try await sut.send(request)

        #expect(data == Data("hello".utf8))
    }

    @Test(arguments: [201, 204, 304, 404, 500])
    func throwsUnexpectedStatusForAnyOtherCode(statusCode: Int) async {
        StubURLProtocol.stub = .init(statusCode: statusCode, headers: ["x-correlation-id": "abc-123"])

        let error = await #expect(throws: NetworkError.self) {
            try await sut.send(request)
        }

        guard case let .unexpectedStatus(response) = error else {
            Issue.record("Expected unexpectedStatus, got \(String(describing: error))")
            return
        }
        #expect(response.statusCode == statusCode)
        #expect(response.value(forHTTPHeaderField: "x-correlation-id") == "abc-123")
    }

    @Test func wrapsTransportErrors() async {
        StubURLProtocol.stub = .init(error: URLError(.notConnectedToInternet))

        let error = await #expect(throws: NetworkError.self) {
            try await sut.send(request)
        }

        guard case let .transport(underlying) = error else {
            Issue.record("Expected transport, got \(String(describing: error))")
            return
        }
        #expect((underlying as? URLError)?.code == .notConnectedToInternet)
    }

    @Test func decodesJSONBody() async throws {
        StubURLProtocol.stub = .init(statusCode: 200, body: Data(#"[{"id":1},null]"#.utf8))

        let items = try await sut.send(request, decoding: [Item?].self)

        #expect(items == [Item(id: 1), nil])
    }

    @Test func wrapsDecodingErrorForMismatchedBody() async {
        StubURLProtocol.stub = .init(statusCode: 200, body: Data(#"{"unexpected":true}"#.utf8))

        let error = await #expect(throws: NetworkError.self) {
            try await sut.send(request, decoding: [Item].self)
        }

        guard case let .decoding(underlying) = error else {
            Issue.record("Expected decoding, got \(String(describing: error))")
            return
        }
        #expect(underlying is DecodingError)
    }
}

private struct Item: Decodable, Equatable {
    let id: Int
}

private final class StubURLProtocol: URLProtocol {
    struct Stub {
        var statusCode = 200
        var headers: [String: String] = [:]
        var body = Data()
        var error: URLError?
    }

    nonisolated(unsafe) static var stub = Stub()

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let stub = Self.stub
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: stub.statusCode,
            httpVersion: nil,
            headerFields: stub.headers
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stub.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
