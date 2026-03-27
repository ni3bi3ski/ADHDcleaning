import SwiftUI
import Combine
import UserNotifications

@MainActor
final class AppViewModel: ObservableObject {

    // MARK: - Cloud Sync
    private let cloudSync = CloudSyncManager()

    // MARK: - Published state
    @Published var tasks: [CleaningTask] = [] {
        didSet { saveTasks() }
    }
    @Published var experience: Int = 0 {
        didSet { UserDefaults.standard.set(experience, forKey: "experience") }
    }
    @Published var streak: Int = 0 {
        didSet { UserDefaults.standard.set(streak, forKey: "streak") }
    }
    @Published var gold: Int = 0 {
        didSet { UserDefaults.standard.set(gold, forKey: "gold") }
    }
    @Published var playerHP: Int = 100 {
        didSet {
            UserDefaults.standard.set(playerHP, forKey: "playerHP")
            if playerHP <= 0 {
                playerHP = 100
                streak = 0
                gold = max(0, gold - 50)
            }
        }
    }
    @Published var dailyStats: [DailyStats] = [] {
        didSet { saveDailyStats() }
    }
    @Published var weekHistory: [WeekHistory] = [] {
        didSet { saveWeekHistory() }
    }
    @Published var lastResetDate: Date = Date() {
        didSet { UserDefaults.standard.set(lastResetDate, forKey: "lastResetDate") }
    }
    @Published var lastDailyReset: Date = Date() {
        didSet { UserDefaults.standard.set(lastDailyReset, forKey: "lastDailyReset") }
    }
    @Published var achievements: [Achievement] = Achievement.all {
        didSet { saveAchievements() }
    }
    @Published var shopItems: [ShopItem] = ShopItem.defaults {
        didSet { saveShopItems() }
    }
    @Published var profile: PlayerProfile = PlayerProfile() {
        didSet { saveProfile() }
    }
    @Published var weeklyChallenge: WeeklyChallenge? = nil {
        didSet { saveWeeklyChallenge() }
    }

    // MARK: - Bannery
    @Published var showWeeklyResetBanner: Bool      = false
    @Published var showLevelUpBanner: Bool          = false
    @Published var levelUpValue: Int                = 0
    @Published var newlyUnlockedAchievement: Achievement? = nil
    @Published var showAchievementBanner: Bool      = false
    @Published var showChallengeCompletedBanner: Bool = false
    @Published var showDailyPenaltyBanner: Bool     = false
    @Published var dailyPenaltyAmount: Int          = 0

    // MARK: - Daily Wheel
    @Published var wheelReward: WheelReward? = nil
    @Published var showWheel: Bool = false

    // MARK: - Focus Timer
    @Published var focusTimerActive: Bool       = false
    @Published var focusTimeElapsed: TimeInterval = 0
    private var focusStartTime: Date            = Date()
    private var focusTimerCancellable: AnyCancellable?

    // MARK: - Chaos Mode
    @Published var chaosModeActive: Bool = false

    // MARK: - Mood
    @Published var currentMood: MoodLevel? = nil

    // MARK: - Combo
    @Published var comboCount: Int      = 0
    @Published var isInComboState: Bool = false

    // MARK: - Flashes
    @Published var showDoubleGoldFlash: Bool = false
    @Published var showTripleXPFlash: Bool   = false

    // MARK: - Pet Expedition
    @Published var lastClaimedExpeditionReward: String? = nil
    @Published var showExpeditionRewardBanner: Bool     = false

    // MARK: - XP Thresholds
    private static let xpThresholds: [Int] = {
        var t: [Int] = [0]
        for lvl in 1...9 { t.append(t.last! + lvl * 100) }
        return t
    }()

    // MARK: - Computed
    var level: Int {
        let t = AppViewModel.xpThresholds
        for i in stride(from: t.count - 1, through: 0, by: -1) {
            if experience >= t[i] { return i + 1 }
        }
        return 1
    }

    var isMasterLevel: Bool  { level >= 10 }
    var xpForNextLevel: Int  { isMasterLevel ? 0 : level * 100 }
    var levelProgress: Double {
        guard !isMasterLevel else { return 1.0 }
        let t = AppViewModel.xpThresholds
        let base   = t[level - 1]
        let needed = level * 100
        return min(1.0, Double(experience - base) / Double(needed))
    }

    var weekNumber: Int             { Calendar.current.component(.weekOfYear, from: lastResetDate) }
    var pendingTasks: [CleaningTask] { tasks.filter { !$0.isDone } }
    var randomTask: CleaningTask?   { pendingTasks.randomElement() }
    var unlockedAchievements: [Achievement] { achievements.filter { $0.isUnlocked } }
    var equippedItems: [InventoryItem]      { profile.inventory.filter { $0.isEquipped } }
    var activePets: [Pet]                   { profile.pets }
    var hasSpunWheelToday: Bool             { profile.dailyWheelLastSpin?.isToday ?? false }

    var hasTurboClean:  Bool { profile.skills.contains("TurboClean") }
    var hasGoldRush:    Bool { profile.skills.contains("GoldRush") }
    var hasFocusMaster: Bool { profile.skills.contains("FocusMaster") }
    var hasIronWill:    Bool { profile.skills.contains("IronWill") }
    var hasLuckyStrike: Bool { profile.skills.contains("LuckyStrike") }

    // MARK: - Today Stats
    var todayTasksCompleted: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyStats
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.tasksCompleted }
    }
    var todayTotalTasks: Int { tasks.filter { $0.frequency == .daily }.count }

    // MARK: - Init
    private var dailyResetCancellable: AnyCancellable?

    init() {
        loadTasks()
        experience  = UserDefaults.standard.integer(forKey: "experience")
        streak      = UserDefaults.standard.integer(forKey: "streak")
        gold        = UserDefaults.standard.integer(forKey: "gold")
        playerHP    = UserDefaults.standard.integer(forKey: "playerHP")
        if playerHP == 0 { playerHP = 100 }
        lastResetDate  = UserDefaults.standard.object(forKey: "lastResetDate")  as? Date ?? Date()
        lastDailyReset = UserDefaults.standard.object(forKey: "lastDailyReset") as? Date ?? Date()
        loadDailyStats()
        loadWeekHistory()
        loadAchievements()
        loadShopItems()
        loadProfile()
        loadWeeklyChallenge()
        checkWeeklyReset()
        refreshWeeklyChallenge()
        setupDailyResetCheck()
        loadFromCloud()
        requestNotificationPermission()
        scheduleDailyNotifications()
    }

    // MARK: - Toggle zadania
    func toggle(task: CleaningTask) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        let wasAlreadyDone = tasks[idx].isDone
        tasks[idx].isDone.toggle()

        if !wasAlreadyDone {
            tasks[idx].lastCompleted = Date()
            let oldLevel = level

            let baseExp  = tasks[idx].exp
            let baseGold = tasks[idx].gold

            let (classExp, classGold) = applyClassBonuses(baseExp: baseExp, baseGold: baseGold, task: tasks[idx])

            let xpMultiplier   = profile.hasActiveDoubleXP  ? 2.0 : 1.0
            let goldMultiplier = profile.hasActiveGoldBoost ? 1.5 : 1.0

            var finalExp  = Int(Double(classExp)  * xpMultiplier)
            var finalGold = Int(Double(classGold) * goldMultiplier)

            if isInComboState {
                let comboMultiplier = 1.0 + Double(min(comboCount, 7)) * 0.10
                finalExp  = Int(Double(finalExp)  * comboMultiplier)
                finalGold = Int(Double(finalGold) * comboMultiplier)
            }

            if hasTurboClean  { finalExp  = Int(Double(finalExp)  * 1.5) }
            if hasGoldRush    { finalGold = Int(Double(finalGold) * 1.5) }

            if hasLuckyStrike && Double.random(in: 0...1) < 0.10 {
                finalExp *= 3
                DispatchQueue.main.async {
                    withAnimation { self.showTripleXPFlash = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation { self.showTripleXPFlash = false }
                    }
                }
            }

            experience += finalExp
            gold       += finalGold

            let petBonus = activePets.reduce(0) { $0 + $1.bonusXP }
            if petBonus > 0 { experience += petBonus }

            let dex  = profile.stats[.dexterity,     default: 1]
            let int_ = profile.stats[.intelligence,  default: 1]
            if dex  > 5 { experience += finalExp / 4 }
            if int_ > 5 { experience += finalExp / 4 }

            recordDailyStat(exp: finalExp)
            updateProfile(for: tasks[idx])
            updateChallenge(for: tasks[idx])
            updateComboState()

            let newLevel = level
            if newLevel > oldLevel {
                levelUpValue = newLevel
                grantLevelUpPoints()
                withAnimation { showLevelUpBanner = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { self.showLevelUpBanner = false }
                }
                scheduleLevelUpNotification(newLevel: newLevel)
            }

            checkAchievements()
        } else {
            tasks[idx].lastCompleted = nil
            experience = max(0, experience - tasks[idx].exp / 2)
            gold       = max(0, gold       - tasks[idx].gold / 2)
            if !profile.hasSkipPenalty { playerHP -= 2 }
            updateComboState()
        }

        saveToCloud()
    }

    // MARK: - Class Bonuses
    func applyClassBonuses(baseExp: Int, baseGold: Int, task: CleaningTask) -> (exp: Int, gold: Int) {
        var exp  = baseExp
        var gold = baseGold

        switch profile.playerClass {
        case .warrior:
            if [.kitchen, .fitness].contains(task.category) { exp = Int(Double(exp) * 1.20) }
        case .mage:
            if [.focus, .bedroom].contains(task.category)   { exp = Int(Double(exp) * 1.30) }
        case .rogue:
            if Double.random(in: 0...1) < 0.15 {
                gold *= 2
                DispatchQueue.main.async {
                    withAnimation { self.showDoubleGoldFlash = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation { self.showDoubleGoldFlash = false }
                    }
                }
            }
        case .cleric:
            if [.health, .fitness].contains(task.category) { playerHP = min(100, playerHP + 2) }
        case .ranger:
            if streak >= 3 {
                exp  = Int(Double(exp)  * 1.10)
                gold = Int(Double(gold) * 1.10)
            }
        }

        return (exp, gold)
    }

    // MARK: - HP Penalty
    func hpPenaltyForMissedTask() -> Int {
        let base: Int
        switch profile.playerClass {
        case .warrior: base = 3
        case .cleric:  base = 2
        default:       base = 5
        }
        return hasIronWill ? max(1, base / 2) : base
    }

    // MARK: - Combo State
    private func updateComboState() {
        let recentCount = tasks.filter { task in
            guard let completed = task.lastCompleted else { return false }
            return Date().timeIntervalSince(completed) < 3600
        }.count
        comboCount    = recentCount
        isInComboState = recentCount >= 3
    }

    // MARK: - Daily Wheel
    func spinWheel() {
        guard !hasSpunWheelToday else { return }
        let reward = WheelReward.allCases.randomElement()!
        wheelReward = reward
        profile.dailyWheelLastSpin = Date()
        applyWheelReward(reward)
        saveToCloud()
        withAnimation { showWheel = true }
    }

    private func applyWheelReward(_ reward: WheelReward) {
        switch reward {
        case .doubleXP:    profile.activeBoosts["doubleXP"]    = Date().addingTimeInterval(86400)
        case .freePotion:  giveFreePotion()
        case .goldBoost:   profile.activeBoosts["goldBoost"]   = Date().addingTimeInterval(86400)
        case .skipPenalty: profile.activeBoosts["skipPenalty"] = Date().addingTimeInterval(86400)
        case .streakSaver: streak += 1
        case .mysteryBox:  mysteryBoxReward()
        }
    }

    private func giveFreePotion()   { playerHP = min(100, playerHP + 30) }
    private func mysteryBoxReward() { gold += [50, 100, 200].randomElement()! }

    // MARK: - Focus Timer
    func startFocusTimer() {
        focusTimerActive  = true
        focusStartTime    = Date()
        focusTimeElapsed  = 0
        focusTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.focusTimeElapsed = Date().timeIntervalSince(self.focusStartTime)
            }
    }

    func stopFocusTimer() {
        guard focusTimerActive else { return }
        focusTimerCancellable?.cancel()
        focusTimerCancellable = nil
        let duration = Date().timeIntervalSince(focusStartTime)
        let session  = FocusSession(startTime: focusStartTime, duration: duration, completedTasks: 0)
        profile.focusSessions.append(session)
        focusTimerActive = false

        if duration >= 600 {
            let timerXP = hasFocusMaster ? 30 : 20
            experience += timerXP
            checkAchievements()
        }
        saveToCloud()
    }

    // MARK: - Chaos Mode
    private var chaosTasks: [CleaningTask] = [
        CleaningTask(title: "1 min sprzątania",     category: .general,  difficulty: .easy),
        CleaningTask(title: "Wypij szklankę wody",  category: .health,   difficulty: .easy),
        CleaningTask(title: "Rozciągnij się 30s",   category: .fitness,  difficulty: .easy),
        CleaningTask(title: "Odpisz 1 wiadomość",   category: .general,  difficulty: .easy),
    ]

    func activateChaosMode() {
        let existingTitles = Set(tasks.map { $0.title })
        let newTasks = chaosTasks.filter { !existingTitles.contains($0.title) }
        tasks.append(contentsOf: newTasks)
        chaosModeActive = true
        profile.chaosBusterMode = true
        saveToCloud()
    }

    func deactivateChaosMode() {
        let chaosTitles = Set(chaosTasks.map { $0.title })
        tasks.removeAll { chaosTitles.contains($0.title) && !$0.isCustom }
        chaosModeActive = false
        profile.chaosBusterMode = false
        saveToCloud()
    }

    func toggleChaosMode() { chaosModeActive ? deactivateChaosMode() : activateChaosMode() }

    // MARK: - Mood Tracker
    func logMood(_ mood: MoodLevel) {
        currentMood = mood
        profile.moodHistory.append(mood)
        saveToCloud()
    }

    // MARK: - Crafting
    func craftRecipe(_ recipe: CraftRecipe) -> Bool {
        let available = recipe.ingredients.allSatisfy { id in
            shopItems.contains { $0.id.uuidString == id && $0.isPurchased }
        }
        guard available else { return false }
        gold -= recipe.resultCost
        checkAchievements()
        saveToCloud()
        return true
    }

    // MARK: - Stats System
    func allocatePoint(to stat: PlayerStat) {
        guard profile.pointsToAllocate > 0 else { return }
        profile.stats[stat, default: 1] += 1
        profile.pointsToAllocate -= 1
        saveProfile()
        saveToCloud()
        checkAchievements()
    }

    private func grantLevelUpPoints() { profile.pointsToAllocate += 1 }

    // MARK: - Daily Reset + Kary
    private func setupDailyResetCheck() {
        dailyResetCancellable = Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.checkDailyReset() }
    }

    func checkDailyReset() {
        let today = Calendar.current.startOfDay(for: Date())
        guard !Calendar.current.isDate(today, inSameDayAs: lastDailyReset) else { return }

        let notDoneYesterday = tasks.filter { $0.frequency == .daily && !$0.isDone }
        if !notDoneYesterday.isEmpty && !profile.hasSkipPenalty {
            let hpPenalty   = notDoneYesterday.count * hpPenaltyForMissedTask()
            let goldPenalty = notDoneYesterday.count * 2
            playerHP         -= hpPenalty
            gold              = max(0, gold - goldPenalty)
            dailyPenaltyAmount = hpPenalty
            withAnimation { showDailyPenaltyBanner = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation { self.showDailyPenaltyBanner = false }
            }
            schedulepenaltyNotification(hp: hpPenalty)
        }

        for idx in tasks.indices where tasks[idx].frequency == .daily {
            tasks[idx].isDone        = false
            tasks[idx].lastCompleted = nil
        }

        comboCount     = 0
        isInComboState = false
        lastDailyReset = today
        saveToCloud()
    }

    // MARK: - Inventory & Pets
    func buyPet(_ petName: String, icon: String = "🐱") {
        let pet = Pet(name: petName, level: 1, hp: 50, icon: icon)
        profile.pets.append(pet)
        checkAchievements()
        saveToCloud()
    }

    func feedPet(_ pet: Pet) {
        guard let idx = profile.pets.firstIndex(where: { $0.id == pet.id }),
              gold >= 5 else { return }
        profile.pets[idx].hp += 20
        gold -= 5
        if profile.pets[idx].hp > 100 {
            profile.pets[idx].level += 1
            profile.pets[idx].hp    = 50
        }
        checkAchievements()
        saveToCloud()
    }

    // MARK: - Pet Expedition
    func sendPetOnExpedition(_ pet: Pet) {
        guard let idx = profile.pets.firstIndex(where: { $0.id == pet.id }),
              !profile.pets[idx].isOnExpedition else { return }
        profile.pets[idx].isOnExpedition   = true
        profile.pets[idx].expeditionEndTime = Date().addingTimeInterval(8 * 3600)
        saveProfile()
        saveToCloud()

        let content = UNMutableNotificationContent()
        content.title = "\(pet.icon) \(pet.name) wrócił z wyprawy!"
        content.body  = "Sprawdź co przyniósł ze świata!"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 8 * 3600, repeats: false)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "expedition_\(pet.id)", content: content, trigger: trigger)
        )
    }

    func claimExpeditionReward(_ pet: Pet) {
        guard let idx = profile.pets.firstIndex(where: { $0.id == pet.id }),
              profile.pets[idx].expeditionReady,
              profile.pets[idx].isOnExpedition else { return }

        let roll = Int.random(in: 1...100)
        var rewardDescription = ""

        switch roll {
        case 1...50:
            let goldReward = Int.random(in: 10...30) * max(1, pet.level)
            gold += goldReward
            rewardDescription = "+\(goldReward) 🪙 złota"
        case 51...80:
            let expReward = Int.random(in: 20...50) * max(1, pet.level)
            experience += expReward
            rewardDescription = "+\(expReward) ⚡ XP"
        case 81...95:
            profile.activeBoosts["doubleXP"] = Date().addingTimeInterval(7200)
            rewardDescription = "2h 2x XP boost! ⚡"
        case 96...100:
            let item = InventoryItem(name: "Skarb \(pet.name)", icon: "gift.fill",
                                     description: "Rzadkie znalezisko z wyprawy 🗺️")
            profile.inventory.append(item)
            rewardDescription = "Rzadki przedmiot: \(item.name)! 🎁"
        default: break
        }

        profile.pets[idx].isOnExpedition    = false
        profile.pets[idx].expeditionEndTime = nil
        lastClaimedExpeditionReward          = rewardDescription

        withAnimation { showExpeditionRewardBanner = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation { self.showExpeditionRewardBanner = false }
        }

        saveProfile()
        checkAchievements()
        saveToCloud()
    }

    func equipItem(_ item: InventoryItem) {
        for i in profile.inventory.indices { profile.inventory[i].isEquipped = false }
        if let idx = profile.inventory.firstIndex(where: { $0.id == item.id }) {
            profile.inventory[idx].isEquipped = true
        }
        saveToCloud()
    }

    func unlockSkill(_ skillName: String) {
        profile.skills.insert(skillName)
        checkAchievements()
        saveToCloud()
    }

    // MARK: - Avatar
    func equipAvatar(item: AvatarItem) {
        profile.equippedAvatar[item.layer] = item
        checkAchievements()
        saveToCloud()
    }

    func unequipAvatar(layer: AvatarLayer) {
        if layer == .body { return } // ciała nie można zdjąć
        profile.equippedAvatar.removeValue(forKey: layer)
        saveToCloud()
    }

    // MARK: - Profil
    private func updateProfile(for task: CleaningTask) {
        profile.totalTasksCompleted += 1
        profile.totalGoldEarned     += task.gold
        profile.increment(category: task.category)
        for stat in task.category.statType {
            profile.stats[stat, default: 1] += 1
        }
    }

    func updatePlayerName(_ name: String)   { profile.name        = name;  saveToCloud() }
    func updatePlayerAvatar(_ emoji: String){ profile.avatarEmoji  = emoji; saveToCloud() }

    // MARK: - Wyzwanie tygodniowe
    func refreshWeeklyChallenge() {
        let current = Calendar.current.component(.weekOfYear, from: Date())
        if weeklyChallenge == nil || weeklyChallenge?.weekNumber != current {
            weeklyChallenge = WeeklyChallenge.generate(for: current)
        }
    }

    private func updateChallenge(for task: CleaningTask) {
        guard var challenge = weeklyChallenge, !challenge.isCompleted else { return }
        if task.category == challenge.category {
            challenge.currentCount += 1
            weeklyChallenge = challenge
            if challenge.isCompleted {
                let bonusXP = Int(Double(task.exp) * challenge.bonusXPMultiplier)
                experience += bonusXP
                gold       += challenge.bonusGold
                profile.challengesCompleted += 1
                withAnimation { showChallengeCompletedBanner = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { self.showChallengeCompletedBanner = false }
                }
                checkAchievements()
            }
        }
    }

    // MARK: - Sklep
    func buyItem(_ item: ShopItem) {
        guard gold >= item.cost,
              let idx = shopItems.firstIndex(where: { $0.id == item.id }) else { return }
        gold -= item.cost
        shopItems[idx].isPurchased = true

        // Pety
        if item.title.contains("Kot")    { buyPet("Kot Sprzątacz",    icon: "🐱") }
        if item.title.contains("Pies")   { buyPet("Pies Porządkowy",  icon: "🐶") }
        if item.title.contains("Sowa")   { buyPet("Sowa Mądrości",    icon: "🦉") }
        if item.title.contains("Smok")   { buyPet("Smok Motywacji",   icon: "🐉") }
        if item.title.contains("Feniks") { buyPet("Feniks Odrodzenia",icon: "🦅") }

        // Skille
        if item.title.contains("TurboClean")  { unlockSkill("TurboClean") }
        if item.title.contains("GoldRush")    { unlockSkill("GoldRush") }
        if item.title.contains("FocusMaster") { unlockSkill("FocusMaster") }
        if item.title.contains("IronWill")    { unlockSkill("IronWill") }
        if item.title.contains("LuckyStrike") { unlockSkill("LuckyStrike") }

        // Eliksiry
        if item.title.contains("Potion HP")      { playerHP = min(100, playerHP + 30) }
        if item.title.contains("HP Max")         { playerHP = 100 }
        if item.title.contains("Eliksir Streak") { streak += 1 }
        if item.title.contains("XP x2")          { profile.activeBoosts["doubleXP"]  = Date().addingTimeInterval(86400) }
        if item.title.contains("Złoty Eliksir")  { profile.activeBoosts["goldBoost"] = Date().addingTimeInterval(86400) }

        // Przedmioty
        if item.title.contains("Złoty Mop") {
            profile.inventory.append(InventoryItem(name: "Złoty Mop",       icon: "sparkles",     description: "+25% XP bonus"))
        }
        if item.title.contains("Plecak") {
            profile.inventory.append(InventoryItem(name: "Plecak Bohatera", icon: "backpack.fill", description: "+1 slot ekwipunku"))
        }
        if item.title.contains("Zegar") {
            profile.inventory.append(InventoryItem(name: "Zegar Fokusa",    icon: "timer",         description: "+10 XP z każdej sesji"))
        }

        // Ubrania awatara — automatyczne wyposażenie po zakupie
        if item.category == .avatar {
            if let avatarItem = AvatarItem.allItems.first(where: { $0.shopItemId == item.id }) {
                equipAvatar(item: avatarItem)
            }
        }

        checkAchievements()
        saveToCloud()
    }

    func addCustomShopItem(title: String, icon: String, cost: Int) {
        let item = ShopItem(title: title, icon: icon, cost: cost, isCustom: true)
        shopItems.append(item)
        saveToCloud()
    }

    func resetShopItem(_ item: ShopItem) {
        guard let idx = shopItems.firstIndex(where: { $0.id == item.id }) else { return }
        shopItems[idx].isPurchased = false
        saveToCloud()
    }

    // MARK: - Własne zadania
    func addCustomTask(title: String, category: TaskCategory,
                       difficulty: TaskDifficulty, frequency: TaskFrequency = .daily) {
        let task = CleaningTask(title: title, category: category,
                                difficulty: difficulty, frequency: frequency, isCustom: true)
        tasks.append(task)
        checkAchievements()
        saveToCloud()
    }

    func deleteTask(at offsets: IndexSet, in filtered: [CleaningTask]) {
        let idsToDelete = offsets.map { filtered[$0].id }
        tasks.removeAll { idsToDelete.contains($0.id) && $0.isCustom }
        saveToCloud()
    }

    // MARK: - Osiągnięcia
    private func checkAchievements() {
        var updated = achievements

        func unlock(_ id: String) {
            guard let idx = updated.firstIndex(where: { $0.id == id }),
                  !updated[idx].isUnlocked else { return }
            updated[idx].isUnlocked   = true
            updated[idx].unlockedDate = Date()
            let unlocked = updated[idx]
            DispatchQueue.main.async {
                self.newlyUnlockedAchievement = unlocked
                withAnimation { self.showAchievementBanner = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { self.showAchievementBanner = false }
                }
                self.scheduleAchievementNotification(achievement: unlocked)
            }
        }

        if profile.totalTasksCompleted >= 1   { unlock("first_task") }
        if profile.totalTasksCompleted >= 50  { unlock("tasks_50") }
        if profile.totalTasksCompleted >= 100 { unlock("tasks_100") }
        if profile.totalTasksCompleted >= 250 { unlock("tasks_250") }
        if streak >= 4  { unlock("streak_4") }
        if streak >= 7  { unlock("streak_7") }
        if streak >= 12 { unlock("streak_12") }
        if level >= 5   { unlock("level_5") }
        if isMasterLevel { unlock("master") }
        if profile.kitchenTasksCompleted  >= 20 { unlock("kitchen_20") }
        if profile.bathroomTasksCompleted >= 20 { unlock("bathroom_20") }
        if profile.healthTasksCompleted   >= 20 { unlock("health_hero") }
        if profile.fitnessTasksCompleted  >= 7  { unlock("fitness_freak") }
        if profile.focusTasksCompleted    >= 25 { unlock("focus_god") }
        if profile.totalGoldEarned >= 500  { unlock("gold_500") }
        if profile.totalGoldEarned >= 2000 { unlock("gold_2000") }
        if profile.challengesCompleted >= 5 { unlock("challenge_5") }
        if tasks.contains(where: { $0.isCustom }) { unlock("custom_task") }
        if shopItems.contains(where: { $0.isPurchased }) { unlock("shop_first") }
        if !profile.pets.isEmpty { unlock("first_pet") }
        if profile.pets.contains(where: { $0.level >= 5 })  { unlock("pet_master") }
        if profile.pets.count >= 3                           { unlock("pet_collector") }
        if profile.stats.values.contains(where: { $0 >= 10 }) { unlock("stats_max") }
        if profile.skills.count >= 3 { unlock("skill_master") }
        if profile.inventory.count >= 5 { unlock("inventory_full") }
        if profile.focusSessions.count >= 25 { unlock("focus_god") }
        if comboCount >= 5  { unlock("combo_5") }
        if comboCount >= 10 { unlock("combo_10") }
        if profile.pets.contains(where: { !$0.isOnExpedition && $0.level >= 1 }) { unlock("explorer") }

        let weeklyTasks  = tasks.filter { $0.frequency == .weekly }
        let monthlyTasks = tasks.filter { $0.frequency == .monthly }
        if !weeklyTasks.isEmpty  && weeklyTasks.allSatisfy(\.isDone)  { unlock("all_weekly") }
        if !monthlyTasks.isEmpty && monthlyTasks.allSatisfy(\.isDone) { unlock("all_monthly") }

        // Avatar achievements
        let equippedCount = profile.equippedAvatar.keys.filter { $0 != .body }.count
        if equippedCount >= 3 { unlock("avatar_dressed") }
        if profile.equippedAvatar[.hat]?.shopItemId == AvatarShopIDs.crown { unlock("avatar_crown") }

        achievements = updated
    }

    // MARK: - Weekly Reset
    func checkWeeklyReset() {
        let calendar = Calendar.current
        guard let nextMonday = calendar.nextDate(
            after: lastResetDate,
            matching: DateComponents(hour: 0, minute: 0, weekday: 2),
            matchingPolicy: .nextTime
        ) else { return }

        if Date() >= nextMonday {
            archiveCurrentWeek()
            for idx in tasks.indices { tasks[idx].isDone = false }
            updateStreak()
            lastResetDate = Date()
            refreshWeeklyChallenge()
            withAnimation { showWeeklyResetBanner = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation { self.showWeeklyResetBanner = false }
            }
            saveToCloud()
        }
    }

    private func archiveCurrentWeek() {
        let weekStats = dailyStats.filter {
            Calendar.current.isDate($0.date, equalTo: lastResetDate, toGranularity: .weekOfYear)
        }
        guard !weekStats.isEmpty else { return }
        let entry = WeekHistory(
            weekNumber: weekNumber,
            startDate: lastResetDate,
            tasksCompleted: weekStats.reduce(0) { $0 + $1.tasksCompleted },
            expEarned: weekStats.reduce(0) { $0 + $1.expEarned }
        )
        weekHistory.insert(entry, at: 0)
    }

    private func updateStreak() {
        let completedThisWeek = dailyStats.contains {
            Calendar.current.isDate($0.date, equalTo: lastResetDate, toGranularity: .weekOfYear)
            && $0.tasksCompleted > 0
        }
        streak = completedThisWeek ? streak + 1 : 0
        profile.longestStreak = max(profile.longestStreak, streak)
    }

    // MARK: - Stats
    private func recordDailyStat(exp: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        if let idx = dailyStats.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyStats[idx].tasksCompleted += 1
            dailyStats[idx].expEarned      += exp
        } else {
            dailyStats.append(DailyStats(date: today, tasksCompleted: 1, expEarned: exp))
        }
    }

    // MARK: - Reset
    func resetAll() {
        tasks          = CleaningTask.defaults
        experience     = 0
        streak         = 0
        gold           = 0
        playerHP       = 100
        dailyStats     = []
        weekHistory    = []
        lastResetDate  = Date()
        lastDailyReset = Date()
        achievements   = Achievement.all
        shopItems      = ShopItem.defaults
        profile        = PlayerProfile()
        weeklyChallenge = nil
        chaosModeActive = false
        focusTimerActive = false
        comboCount      = 0
        isInComboState  = false
        refreshWeeklyChallenge()
        saveToCloud()
    }

    // MARK: - Cloud Sync
    func loadFromCloud() {
        Task { @MainActor in
            let remote = await cloudSync.load()
            guard let remote else { saveToCloud(); startCloudListener(); return }
            let local  = makePayload()
            let merged = cloudSync.merge(local: local, remote: remote)
            applyPayload(merged)
            saveToCloud()
            startCloudListener()
        }
    }

    func startCloudListener() {
        cloudSync.startListening { [weak self] remote in
            guard let self else { return }
            DispatchQueue.main.async {
                let local  = self.makePayload()
                let merged = self.cloudSync.merge(local: local, remote: remote)
                self.applyPayload(merged)
            }
        }
    }

    func saveToCloud() { cloudSync.save(makePayload()) }

    // Alias dla zgodności z AvatarDressingRoomView
    func saveData() { saveToCloud() }

    private func makePayload() -> SyncPayload {
        SyncPayload(
            tasks: tasks, experience: experience, streak: streak,
            gold: gold, playerHP: playerHP, lastResetDate: lastResetDate,
            lastDailyReset: lastDailyReset, dailyStats: dailyStats,
            weekHistory: weekHistory, achievements: achievements,
            shopItems: shopItems, profile: profile, weeklyChallenge: weeklyChallenge
        )
    }

    private func applyPayload(_ p: SyncPayload) {
        tasks          = p.tasks
        experience     = p.experience
        streak         = p.streak
        gold           = p.gold
        playerHP       = p.playerHP
        lastResetDate  = p.lastResetDate
        lastDailyReset = p.lastDailyReset
        dailyStats     = p.dailyStats
        weekHistory    = p.weekHistory
        achievements   = p.achievements
        shopItems      = p.shopItems
        profile        = p.profile
        weeklyChallenge = p.weeklyChallenge
    }

    // MARK: - Powiadomienia
    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func scheduleDailyNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Tasks! \(profile.avatarEmoji)"
        content.body  = activePets.isEmpty
            ? "Sprawdź zadania zanim stracisz HP!"
            : "Twój pet czeka! Sprawdź zadania"
        content.sound = .default
        var dc = DateComponents()
        dc.hour = 8; dc.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "daily-tasks-adhd", content: content, trigger: trigger)
        )
    }

    private func scheduleLevelUpNotification(newLevel: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Awans! 🎉"
        content.body  = "Osiągnąłeś poziom \(newLevel)! Tak trzymaj!"
        content.sound = .default
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: "levelup-\(newLevel)", content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            )
        )
    }

    private func scheduleAchievementNotification(achievement: Achievement) {
        let content = UNMutableNotificationContent()
        content.title = "Osiągnięcie! \(achievement.icon)"
        content.body  = "\(achievement.title) — \(achievement.description)"
        content.sound = .default
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: "achievement-\(achievement.id)", content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            )
        )
    }

    private func schedulepenaltyNotification(hp: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Kara! 💀"
        content.body  = "Pominąłeś daily tasks. Straciłeś \(hp) HP!"
        content.sound = .default
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: "penalty-\(Date().timeIntervalSince1970)", content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            )
        )
    }

    // MARK: - Persistence
    private func saveTasks() {
        if let d = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(d, forKey: "tasks-v2")
        }
    }
    private func loadTasks() {
        if let d = UserDefaults.standard.data(forKey: "tasks-v2"),
           let v = try? JSONDecoder().decode([CleaningTask].self, from: d) {
            tasks = v
        } else {
            tasks = CleaningTask.defaults
        }
    }
    private func saveDailyStats() {
        if let d = try? JSONEncoder().encode(dailyStats) {
            UserDefaults.standard.set(d, forKey: "dailyStats")
        }
    }
    private func loadDailyStats() {
        if let d = UserDefaults.standard.data(forKey: "dailyStats"),
           let v = try? JSONDecoder().decode([DailyStats].self, from: d) {
            dailyStats = v
        }
    }
    private func saveWeekHistory() {
        if let d = try? JSONEncoder().encode(weekHistory) {
            UserDefaults.standard.set(d, forKey: "weekHistory")
        }
    }
    private func loadWeekHistory() {
        if let d = UserDefaults.standard.data(forKey: "weekHistory"),
           let v = try? JSONDecoder().decode([WeekHistory].self, from: d) {
            weekHistory = v
        }
    }
    private func saveAchievements() {
        if let d = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(d, forKey: "achievements")
        }
    }
    private func loadAchievements() {
        if let d = UserDefaults.standard.data(forKey: "achievements"),
           let v = try? JSONDecoder().decode([Achievement].self, from: d) {
            achievements = v
        } else {
            achievements = Achievement.all
        }
    }
    private func saveShopItems() {
        if let d = try? JSONEncoder().encode(shopItems) {
            UserDefaults.standard.set(d, forKey: "shopItems")
        }
    }
    private func loadShopItems() {
        if let d = UserDefaults.standard.data(forKey: "shopItems"),
           let v = try? JSONDecoder().decode([ShopItem].self, from: d) {
            shopItems = v
        } else {
            shopItems = ShopItem.defaults
        }
    }
    private func saveProfile() {
        if let d = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(d, forKey: "profile")
        }
    }
    private func loadProfile() {
        if let d = UserDefaults.standard.data(forKey: "profile"),
           let v = try? JSONDecoder().decode(PlayerProfile.self, from: d) {
            profile = v
        }
    }
    private func saveWeeklyChallenge() {
        if let d = try? JSONEncoder().encode(weeklyChallenge) {
            UserDefaults.standard.set(d, forKey: "weeklyChallenge")
        }
    }
    private func loadWeeklyChallenge() {
        if let d = UserDefaults.standard.data(forKey: "weeklyChallenge"),
           let v = try? JSONDecoder().decode(WeeklyChallenge?.self, from: d) {
            weeklyChallenge = v
        }
    }
}
