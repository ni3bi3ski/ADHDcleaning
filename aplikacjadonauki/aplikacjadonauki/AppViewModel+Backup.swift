import Foundation

extension AppViewModel {

    func exportBackupData() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(makePayload())
    }

    @discardableResult
    func importBackupData(_ data: Data) -> Bool {
        guard let payload = try? JSONDecoder().decode(SyncPayload.self, from: data) else { return false }
        applyPayload(payload)
        saveToCloud()
        return true
    }

    /// Tryb choroby: 24 h bez kar za HP i złoto (wykorzystuje boost skipPenalty).
    func activateSickDay(hours: Double = 24) {
        profile.activeBoosts["skipPenalty"] = Date().addingTimeInterval(hours * 3600)
    }

    func deactivateSickDay() {
        profile.activeBoosts.removeValue(forKey: "skipPenalty")
    }
}
