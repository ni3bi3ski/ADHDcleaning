import Foundation

/// Lokalna kopia JSON. Nazwa zachowana dla zgodności z AppViewModel.
@MainActor
final class CloudSyncManager {
    private let queue = DispatchQueue(label: "local.backup", qos: .utility)

    private var fileURL: URL? {
        guard let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            return dir.appendingPathComponent("backup.json")
        } catch {
            print("Local backup directory failed: \(error)")
            return nil
        }
    }

    func save(_ payload: SyncPayload) {
        guard let url = fileURL else { return }
        do {
            let data = try JSONEncoder().encode(payload)
            queue.async {
                do { try data.write(to: url, options: .atomic) }
                catch { print("Local backup write failed: \(error)") }
            }
        } catch {
            print("Local backup encoding failed: \(error)")
        }
    }

    func load() async -> SyncPayload? {
        guard let url = fileURL else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(SyncPayload.self, from: data)
        } catch {
            print("Local backup load failed: \(error)")
            return nil
        }
    }

    func startListening(onChange: @escaping (SyncPayload) -> Void) {}
    func stopListening() {}
    func merge(local: SyncPayload, remote: SyncPayload) -> SyncPayload { local }
}
