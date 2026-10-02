import Foundation

public enum NetworkError: Error, Sendable {
    case invalidURL
    case transport(any Error)
    case invalidResponse
    case unexpectedStatus(HTTPURLResponse)
    case decoding(any Error)
}
