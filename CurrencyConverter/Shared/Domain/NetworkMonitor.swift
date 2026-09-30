nonisolated protocol NetworkMonitor: Sendable {
    var isConnected: Bool { get async }
    func connectivityUpdates() -> AsyncStream<Bool>
}
