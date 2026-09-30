nonisolated struct TickerDTO: Decodable, Sendable {
    let ask: String
    let bid: String
    let book: String
}
