@testable import CurrencyConverter
import Foundation
import Testing

struct FileExchangeRatesSnapshotStoreTests {
    private let directory = FileManager.default.temporaryDirectory
        .appending(path: "FileExchangeRatesSnapshotStoreTests-\(UUID().uuidString)")

    private var fileURL: URL { directory.appending(path: "nested/snapshot.json") }

    private func snapshot(ask: String, bid: String, fetchedAt: TimeInterval = 1_790_000_000) throws -> ExchangeRatesSnapshot {
        try ExchangeRatesSnapshot(
            rates: [ExchangeRate(
                quoteCurrency: Currency(code: "MXN"),
                ask: #require(Decimal(string: ask)),
                bid: #require(Decimal(string: bid)),
                quotedAt: Date(timeIntervalSince1970: fetchedAt - 0.5)
            )],
            fetchedAt: Date(timeIntervalSince1970: fetchedAt)
        )
    }

    @Test func roundTripKeepsFullDecimalPrecisionAndDate() throws {
        let sut = FileExchangeRatesSnapshotStore(fileURL: fileURL)
        let saved = try snapshot(ask: "18.4097123456", bid: "18.3987654321", fetchedAt: 1_790_000_000.123)

        try sut.save(saved)

        #expect(sut.load() == saved)
    }

    @Test func saveCreatesMissingParentDirectory() throws {
        let sut = FileExchangeRatesSnapshotStore(fileURL: fileURL)

        try sut.save(snapshot(ask: "1", bid: "1"))

        #expect(FileManager.default.fileExists(atPath: fileURL.path()))
    }

    @Test func secondSaveOverwritesTheFirst() throws {
        let sut = FileExchangeRatesSnapshotStore(fileURL: fileURL)
        let latest = try snapshot(ask: "20.5", bid: "20.4")

        try sut.save(snapshot(ask: "18.41", bid: "18.40"))
        try sut.save(latest)

        #expect(sut.load() == latest)
    }

    @Test func missingFileLoadsNil() {
        let sut = FileExchangeRatesSnapshotStore(fileURL: fileURL)

        #expect(sut.load() == nil)
    }

    @Test func corruptFileLoadsNil() throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: fileURL)
        let sut = FileExchangeRatesSnapshotStore(fileURL: fileURL)

        #expect(sut.load() == nil)
    }

    @Test(arguments: [
        #"{"rates":[{"quoteCurrencyCode":"MXN","ask":"abc","bid":"18.4"}],"fetchedAt":0}"#,
        #"{"rates":[{"quoteCurrencyCode":"MXN","ask":"0","bid":"18.4"}],"fetchedAt":0}"#,
        #"{"rates":[{"quoteCurrencyCode":"MXN","ask":"18.41","bid":"-18.4"}],"fetchedAt":0}"#,
        #"{"rates":[],"fetchedAt":0}"#,
    ])
    func unusableSnapshotLoadsNil(json: String) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(json.utf8).write(to: fileURL)
        let sut = FileExchangeRatesSnapshotStore(fileURL: fileURL)

        #expect(sut.load() == nil)
    }
}
