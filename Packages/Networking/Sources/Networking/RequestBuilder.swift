import Foundation

public struct RequestBuilder: Sendable {
    private let baseURL: URL
    private var path = ""
    private var method = HTTPMethod.get
    private var queryItems: [URLQueryItem] = []
    private var headers: [String: String] = [:]
    private var body: Data?

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func path(_ path: String) -> RequestBuilder {
        with { $0.path = path }
    }

    public func method(_ method: HTTPMethod) -> RequestBuilder {
        with { $0.method = method }
    }

    public func query(_ name: String, _ value: String) -> RequestBuilder {
        with { $0.queryItems.append(URLQueryItem(name: name, value: value)) }
    }

    public func header(_ name: String, _ value: String) -> RequestBuilder {
        with { $0.headers[name] = value }
    }

    public func body(_ body: Data) -> RequestBuilder {
        with { $0.body = body }
    }

    public func build() throws(NetworkError) -> URLRequest {
        guard var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false) else {
            throw .invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw .invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }

    private func with(_ update: (inout RequestBuilder) -> Void) -> RequestBuilder {
        var copy = self
        update(&copy)
        return copy
    }
}
