nonisolated enum APIError: Error, Equatable, Sendable {
    case transport(String)
    case unexpectedStatus(Int, correlationID: String?)
    case decoding(String, correlationID: String?)
    /// A 200 whose tickers were all null or failed validation - nothing to convert with.
    case noUsableRates(correlationID: String?)
}
