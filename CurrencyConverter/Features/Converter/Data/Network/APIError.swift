nonisolated enum APIError: Error, Sendable {
    case transport(String)
    case unexpectedStatus(Int, correlationID: String?)
    case decoding(String, correlationID: String?)
}
