/// Persists the last successfully fetched snapshot so rates survive a restart without network.
nonisolated protocol ExchangeRatesSnapshotStore: Sendable {
    /// `nil` when nothing was saved yet or the stored data can't be read.
    func load() -> ExchangeRatesSnapshot?
    func save(_ snapshot: ExchangeRatesSnapshot) throws
}
