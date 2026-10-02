import Foundation

public struct RequestBuilder: Sendable {
    private let baseURL: URL
    private var path = ""
    private var queryItems: [URLQueryItem] = []

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func path(_ path: String) -> RequestBuilder {
        with { $0.path = path }
    }

    public func query(_ name: String, _ value: String) -> RequestBuilder {
        with { $0.queryItems.append(URLQueryItem(name: name, value: value)) }
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

        return URLRequest(url: url)
    }
}

private extension RequestBuilder {
    func with(_ update: (inout RequestBuilder) -> Void) -> RequestBuilder {
        var copy = self
        update(&copy)
        return copy
    }
}
