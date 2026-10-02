import Foundation
import Network

nonisolated struct NWPathNetworkMonitor: NetworkMonitor {
    nonisolated var isConnected: Bool {
        get async {
            await connectivityUpdates().first { _ in true } ?? false
        }
    }

    nonisolated func connectivityUpdates() -> AsyncStream<Bool> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                continuation.yield(path.status == .satisfied)
            }
            continuation.onTermination = { _ in
                monitor.cancel()
            }
            monitor.start(queue: DispatchQueue(label: "NWPathNetworkMonitor"))
        }
    }
}
