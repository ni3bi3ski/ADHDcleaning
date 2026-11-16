import Foundation

extension AppViewModel {

    func exportBackupData() -> Data? {
        let payload = SyncPayload(
            tasks: tasks,
            experience: experience,
            streak: streak,
            gold: gold,
            playerHP: playerHP,
            lastResetDate: lastResetDate,
            lastDailyReset: lastDailyReset,
            dailyStats: dailyStats,
            weekHistory: weekHistory,
            achievements: achievements,
            shopItems: shopItems,
            profile: profile,
            weeklyChallenge: weeklyChallenge
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(payload)
    }

    @discardableResult
    func importBackupData(_ data: Data) -> Bool {
        guard let p = try? JSONDecoder().decode(SyncPayload.self, from: data) else { return false }
        tasks = p.tasks
        experience = p.experience
        streak = p.streak
        gold = p.gold
        playerHP = p.playerHP
        lastResetDate = p.lastResetDate
        lastDailyReset = p.lastDailyReset
        dailyStats = p.dailyStats
        weekHistory = p.weekHistory
        achievements = p.achievements
        shopItems = p.shopItems
        profile = p.profile
        weeklyChallenge = p.weeklyChallenge
        return true
    }

    /// Tryb choroby: 24 h bez kar za HP i złoto (wykorzystuje istniejący boost skipPenalty).
    func activateSickDay(hours: Double = 24) {
        profile.activeBoosts["skipPenalty"] = Date().addingTimeInterval(hours * 3600)
    }

    func deactivateSickDay() {
        profile.activeBoosts.removeValue(forKey: "skipPenalty")
    }
}
