import Foundation
import FirebaseFirestore

class CloudSyncManager {
    private let db = Firestore.firestore()
    private let docID = "shared_save"
    private var listener: ListenerRegistration?

    func save(_ payload: SyncPayload) {
        guard let data = try? JSONEncoder().encode(payload),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return }
        db.collection("sync").document(docID).setData(dict) { error in
            if let error = error { print("❌ Firebase save failed: \(error)") }
            else { print("✅ Firebase save OK") }
        }
    }

    func load() async -> SyncPayload? {
        guard let snapshot = try? await db.collection("sync").document(docID).getDocument(),
              let data = snapshot.data(),
              let jsonData = try? JSONSerialization.data(withJSONObject: data)
        else { return nil }
        return try? JSONDecoder().decode(SyncPayload.self, from: jsonData)
    }

    func startListening(onChange: @escaping (SyncPayload) -> Void) {
        listener = db.collection("sync").document(docID).addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data(),
                  let jsonData = try? JSONSerialization.data(withJSONObject: data),
                  let payload = try? JSONDecoder().decode(SyncPayload.self, from: jsonData)
            else { return }
            onChange(payload)
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

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
            let l = local[stat, default: 1]
            let r = remote[stat, default: 1]
            merged[stat] = max(l, r)
        }
    }

    private func mergeSkills(local: Set<String>, remote: Set<String>) -> Set<String> {
        local.union(remote)
    }
}
