import Foundation

/// Lokalny zapis kopii zapasowej. Brak sieci, brak kont, brak serwera.
/// Źródłem prawdy pozostaje UserDefaults (AppViewModel); ten plik to dodatkowy backup JSON
/// w Application Support oraz logika merge do importu.
class CloudSyncManager {
    private let queue = DispatchQueue(label: "local.backup", qos: .utility)

    private var fileURL: URL? {
        guard let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("backup.json")
    }

    func save(_ payload: SyncPayload) {
        guard let url = fileURL else { return }
        queue.async {
            do {
                let data = try JSONEncoder().encode(payload)
                try data.write(to: url, options: .atomic)
            } catch {
                print("Local backup failed: \(error)")
            }
        }
    }

    func load() async -> SyncPayload? {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(SyncPayload.self, from: data)
    }

    func startListening(onChange: @escaping (SyncPayload) -> Void) {}
    func stopListening() {}

    func merge(local: SyncPayload, remote: SyncPayload) -> SyncPayload {
        SyncPayload(
            tasks: remote.lastResetDate > local.lastResetDate ? remote.tasks : local.tasks,
            experience: max(local.experience, remote.experience),
            streak: max(local.streak, remote.streak),
            gold: max(local.gold, remote.gold),
            playerHP: max(local.playerHP, remote.playerHP),
            lastResetDate: max(local.lastResetDate, remote.lastResetDate),
            lastDailyReset: max(local.lastDailyReset, remote.lastDailyReset),
            dailyStats: local.dailyStats,
            weekHistory: local.weekHistory,
            achievements: mergeAchievements(local: local.achievements, remote: remote.achievements),
            shopItems: local.shopItems,
            profile: mergeProfile(local: local.profile, remote: remote.profile),
            weeklyChallenge: local.weeklyChallenge
        )
    }

    private func mergeAchievements(local: [Achievement], remote: [Achievement]) -> [Achievement] {
        local.map { localAch in
            if let remoteAch = remote.first(where: { $0.id == localAch.id }),
               remoteAch.isUnlocked { return remoteAch }
            return localAch
        }
    }

    private func mergeProfile(local: PlayerProfile, remote: PlayerProfile) -> PlayerProfile {
        PlayerProfile(
            name: local.name,
            avatarEmoji: local.avatarEmoji,
            totalTasksCompleted: max(local.totalTasksCompleted, remote.totalTasksCompleted),
            totalGoldEarned: max(local.totalGoldEarned, remote.totalGoldEarned),
            challengesCompleted: max(local.challengesCompleted, remote.challengesCompleted),
            kitchenTasksCompleted: max(local.kitchenTasksCompleted, remote.kitchenTasksCompleted),
            bathroomTasksCompleted: max(local.bathroomTasksCompleted, remote.bathroomTasksCompleted),
            stats: mergeStats(local: local.stats, remote: remote.stats),
            pointsToAllocate: max(local.pointsToAllocate, remote.pointsToAllocate),
            inventory: local.inventory,
            pets: local.pets,
            playerClass: local.playerClass,
            skills: mergeSkills(local: local.skills, remote: remote.skills)
        )
    }

    private func mergeStats(local: [PlayerStat: Int], remote: [PlayerStat: Int]) -> [PlayerStat: Int] {
        PlayerStat.allCases.reduce(into: local) { merged, stat in
            merged[stat] = max(local[stat, default: 1], remote[stat, default: 1])
        }
    }

    private func mergeSkills(local: Set<String>, remote: Set<String>) -> Set<String> {
        local.union(remote)
    }
}
