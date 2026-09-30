@testable import CurrencyConverter
import Testing

struct NWPathNetworkMonitorTests {
    @Test(.timeLimit(.minutes(1)))
    func connectivityUpdatesStartWithTheCurrentPath() async {
        let first = await NWPathNetworkMonitor().connectivityUpdates().first { _ in true }

        #expect(first != nil)
    }
}
