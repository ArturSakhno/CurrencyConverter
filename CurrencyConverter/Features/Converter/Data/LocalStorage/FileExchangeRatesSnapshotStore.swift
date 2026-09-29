import Foundation

/// Keeps the snapshot as one small JSON file. A database would be overkill for a single
/// value that's always replaced whole. Application Support rather than Caches, because iOS
/// may purge Caches and this file is the offline fallback.
nonisolated struct FileExchangeRatesSnapshotStore: ExchangeRatesSnapshotStore {
    static let defaultFileURL = URL.applicationSupportDirectory.appending(path: "ExchangeRatesSnapshot.json")

    let fileURL: URL

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func load() -> ExchangeRatesSnapshot? {
        guard let data = try? Data(contentsOf: fileURL),
              let dto = try? decoder.decode(CachedExchangeRatesSnapshotDTO.self, from: data)
        else { return nil }
        return dto.toDomain()
    }

    func save(_ snapshot: ExchangeRatesSnapshot) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let data = try encoder.encode(CachedExchangeRatesSnapshotDTO(snapshot))
        // Atomic, so a crash mid-write never leaves a half-written file behind.
        try data.write(to: fileURL, options: .atomic)
    }
}
