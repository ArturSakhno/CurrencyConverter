@testable import CurrencyConverter
import Foundation
import Testing

struct RemoteExchangeRateRepositoryTests {
    private let mxnRate = ExchangeRate(quoteCurrency: Currency(code: "MXN"), ask: 18.42, bid: 18.40)

    @Test func successfulFetchSavesSnapshotToStore() async throws {
        let store = InMemorySnapshotStore()
        let sut = RemoteExchangeRateRepository(apiClient: StubTickersAPIClient(result: .success([mxnRate])), store: store)

        let snapshot = try await sut.fetchLatestRates(base: CurrencyCatalog.base, quotes: [Currency(code: "MXN")])

        #expect(snapshot.rates == [mxnRate])
        #expect(store.load() == snapshot)
    }

    @Test func lastCachedSnapshotReadsFromStore() throws {
        let cached = ExchangeRatesSnapshot(rates: [mxnRate], fetchedAt: Date(timeIntervalSince1970: 0))
        let store = InMemorySnapshotStore()
        try store.save(cached)
        let sut = RemoteExchangeRateRepository(apiClient: StubTickersAPIClient(result: .success([])), store: store)

        #expect(sut.lastCachedSnapshot() == cached)
    }

    @Test func failedFetchThrowsAndKeepsStoredSnapshot() async throws {
        let cached = ExchangeRatesSnapshot(rates: [mxnRate], fetchedAt: Date(timeIntervalSince1970: 0))
        let store = InMemorySnapshotStore()
        try store.save(cached)
        let sut = RemoteExchangeRateRepository(
            apiClient: StubTickersAPIClient(result: .failure(.transport("offline"))),
            store: store
        )

        await #expect(throws: APIError.self) {
            try await sut.fetchLatestRates(base: CurrencyCatalog.base, quotes: [Currency(code: "MXN")])
        }
        #expect(store.load() == cached)
    }

    @Test func failedSaveDoesNotFailTheFetch() async throws {
        let sut = RemoteExchangeRateRepository(
            apiClient: StubTickersAPIClient(result: .success([mxnRate])),
            store: FailingSnapshotStore()
        )

        let snapshot = try await sut.fetchLatestRates(base: CurrencyCatalog.base, quotes: [Currency(code: "MXN")])

        #expect(snapshot.rates == [mxnRate])
    }
}

private struct StubTickersAPIClient: TickersAPIClient {
    let result: Result<[ExchangeRate], APIError>

    func fetchTickers(base _: Currency, quotes _: [Currency]) async throws -> [ExchangeRate] {
        try result.get()
    }
}

private final class InMemorySnapshotStore: ExchangeRatesSnapshotStore, @unchecked Sendable {
    private let lock = NSLock()
    private var snapshot: ExchangeRatesSnapshot?

    func load() -> ExchangeRatesSnapshot? {
        lock.withLock { snapshot }
    }

    func save(_ snapshot: ExchangeRatesSnapshot) throws {
        lock.withLock { self.snapshot = snapshot }
    }
}

private struct FailingSnapshotStore: ExchangeRatesSnapshotStore {
    struct SaveError: Error {}

    func load() -> ExchangeRatesSnapshot? { nil }

    func save(_: ExchangeRatesSnapshot) throws {
        throw SaveError()
    }
}
