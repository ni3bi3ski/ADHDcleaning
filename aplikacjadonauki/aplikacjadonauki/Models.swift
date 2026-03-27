import Foundation
import SwiftUI

// MARK: - Player Stats
enum PlayerStat: String, CaseIterable, Codable, Sendable {
    case strength     = "Siła"
    case intelligence = "Inteligencja"
    case dexterity    = "Zręczność"
    case perception   = "Percepcja"
    case willpower    = "Silna wola"
    case charisma     = "Charyzma"

    var icon: String {
        switch self {
        case .strength:     return "⚔️"
        case .intelligence: return "🧠"
        case .dexterity:    return "✋"
        case .perception:   return "👁️"
        case .willpower:    return "🔥"
        case .charisma:     return "✨"
        }
    }

    var description: String {
        switch self {
        case .strength:     return "+XP za sprzątanie ciężkie"
        case .intelligence: return "+XP za planowanie i fokus"
        case .dexterity:    return "+XP za detale i łazienkę"
        case .perception:   return "+XP za zdrowie i obserwację"
        case .willpower:    return "-HP kara zmniejszona"
        case .charisma:     return "+Gold za zadania"
        }
    }
}

// MARK: - Inventory Item
struct InventoryItem: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var description: String
    var isEquipped: Bool = false

    init(id: UUID = UUID(), name: String, icon: String, description: String, isEquipped: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.description = description
        self.isEquipped = isEquipped
    }
}

// MARK: - Pet
struct Pet: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var name: String
    var level: Int = 1
    var hp: Int = 50
    var icon: String

    var bonusXP: Int   { level * 2 }
    var bonusGold: Int { level }

    var isOnExpedition: Bool  = false
    var expeditionEndTime: Date? = nil

    var expeditionReady: Bool {
        guard let end = expeditionEndTime else { return true }
        return Date() >= end
    }
}

// MARK: - Wheel Reward
enum WheelReward: String, CaseIterable, Codable, Sendable {
    case doubleXP    = "2x XP przez 24h"
    case freePotion  = "Potion HP za darmo"
    case goldBoost   = "+50% Gold przez 24h"
    case skipPenalty = "Brak kar przez 24h"
    case streakSaver = "+1 dzień streak"
    case mysteryBox  = "Skrzynka Tajemnic"

    var icon: String {
        switch self {
        case .doubleXP:    return "bolt.fill"
        case .freePotion:  return "heart.fill"
        case .goldBoost:   return "dollarsign.circle.fill"
        case .skipPenalty: return "shield.fill"
        case .streakSaver: return "flame.fill"
        case .mysteryBox:  return "questionmark.circle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .doubleXP:    return "yellow"
        case .freePotion:  return "red"
        case .goldBoost:   return "yellow"
        case .skipPenalty: return "green"
        case .streakSaver: return "orange"
        case .mysteryBox:  return "purple"
        }
    }
}

// MARK: - Mood Level
enum MoodLevel: String, CaseIterable, Codable, Identifiable, Sendable {
    case terrible = "Fatalnie"
    case bad      = "Słabo"
    case neutral  = "Neutralnie"
    case good     = "Dobrze"
    case great    = "Świetnie"

    var id: String { rawValue }

    var rawEmoji: String {
        switch self {
        case .terrible: return "😭"
        case .bad:      return "😕"
        case .neutral:  return "😐"
        case .good:     return "🙂"
        case .great:    return "😄"
        }
    }

    var colorName: String? {
        switch self {
        case .terrible: return "red"
        case .bad:      return "orange"
        case .neutral:  return "gray"
        case .good:     return "teal"
        case .great:    return "green"
        }
    }
}

// MARK: - Focus Session
struct FocusSession: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var startTime: Date
    var duration: TimeInterval
    var completedTasks: Int
}

// MARK: - Craft Recipe
struct CraftRecipe: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var name: String
    var ingredients: [String]
    var resultCost: Int
    var resultIcon: String

    static let defaults: [CraftRecipe] = [
        CraftRecipe(name: "Epic HP Potion", ingredients: [], resultCost: 75,  resultIcon: "heart.circle.fill"),
        CraftRecipe(name: "XP Mega Boost",  ingredients: [], resultCost: 150, resultIcon: "bolt.circle.fill"),
    ]
}

// MARK: - Częstotliwość zadania
enum TaskFrequency: String, CaseIterable, Codable, Sendable {
    case daily   = "Dzienne"
    case weekly  = "Tygodniowe"
    case monthly = "Miesięczne"

    var icon: String {
        switch self {
        case .daily:   return "sun.max.fill"
        case .weekly:  return "calendar.badge.clock"
        case .monthly: return "calendar"
        }
    }
}

// MARK: - Kategoria zadania
enum TaskCategory: String, CaseIterable, Codable, Sendable {
    case kitchen  = "Kuchnia"
    case bathroom = "Łazienka"
    case living   = "Salon"
    case bedroom  = "Sypialnia"
    case general  = "Ogólne"
    case health   = "Zdrowie"
    case fitness  = "Fitness"
    case focus    = "Fokus"
    case finance  = "Finanse"
    case social   = "Społeczne"
    case selfcare = "Dbanie o siebie"
    case work     = "Praca/Nauka"
    case custom   = "Własne"

    var icon: String {
        switch self {
        case .kitchen:  return "fork.knife"
        case .bathroom: return "shower.fill"
        case .living:   return "sofa.fill"
        case .bedroom:  return "bed.double.fill"
        case .general:  return "house.fill"
        case .health:   return "heart.fill"
        case .fitness:  return "figure.walk"
        case .focus:    return "brain.head.profile"
        case .finance:  return "banknote.fill"
        case .social:   return "bubble.left.and.bubble.right.fill"
        case .selfcare: return "figure.mind.and.body"
        case .work:     return "pencil.and.list.clipboard"
        case .custom:   return "plus.circle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .kitchen:  return "orange"
        case .bathroom: return "blue"
        case .living:   return "purple"
        case .bedroom:  return "indigo"
        case .general:  return "green"
        case .health:   return "red"
        case .fitness:  return "mint"
        case .focus:    return "teal"
        case .finance:  return "yellow"
        case .social:   return "cyan"
        case .selfcare: return "pink"
        case .work:     return "orange"
        case .custom:   return "gray"
        }
    }

    var statType: [PlayerStat] {
        switch self {
        case .kitchen:  return [.strength]
        case .bathroom: return [.dexterity]
        case .living:   return [.perception]
        case .bedroom:  return [.intelligence]
        case .general:  return [.strength, .dexterity]
        case .health:   return [.perception, .willpower]
        case .fitness:  return [.strength, .willpower]
        case .focus:    return [.intelligence]
        case .finance:  return [.intelligence, .willpower]
        case .social:   return [.charisma]
        case .selfcare: return [.willpower, .perception]
        case .work:     return [.intelligence, .dexterity]
        case .custom:   return []
        }
    }

    var subtitle: String {
        switch self {
        case .kitchen:  return "Gotowanie, zmywanie"
        case .bathroom: return "Higiena, porządki"
        case .living:   return "Salon, kurze"
        case .bedroom:  return "Sypialnia, pościel"
        case .general:  return "Dom ogólnie"
        case .health:   return "Woda, leki, sen"
        case .fitness:  return "Ruch, sport"
        case .focus:    return "Pomodoro, planowanie"
        case .finance:  return "Rachunki, budżet"
        case .social:   return "Wiadomości, relacje"
        case .selfcare: return "Prysznic, pielęgnacja"
        case .work:     return "Nauka, projekty"
        case .custom:   return "Własne zadania"
        }
    }
}

// MARK: - Trudność zadania
enum TaskDifficulty: String, CaseIterable, Codable, Sendable {
    case easy   = "Łatwe"
    case medium = "Średnie"
    case hard   = "Trudne"

    var icon: String {
        switch self {
        case .easy:   return "⚡"
        case .medium: return "🔥"
        case .hard:   return "💀"
        }
    }

    var xpMultiplier: Double {
        switch self {
        case .easy:   return 1.0
        case .medium: return 1.5
        case .hard:   return 2.0
        }
    }
}

// MARK: - Zadanie
struct CleaningTask: Identifiable, Codable, Equatable, Sendable {
    var id: UUID = UUID()
    var title: String
    var isDone: Bool = false
    var category: TaskCategory
    var difficulty: TaskDifficulty
    var frequency: TaskFrequency = .daily
    var isCustom: Bool = false
    var lastCompleted: Date? = nil
    var note: String? = nil
    var reminderHour: Int? = nil

    var exp: Int {
        switch (frequency, difficulty) {
        case (.daily,   .easy):   return 15
        case (.daily,   .medium): return 25
        case (.daily,   .hard):   return 40
        case (.weekly,  .easy):   return 30
        case (.weekly,  .medium): return 50
        case (.weekly,  .hard):   return 75
        case (.monthly, .easy):   return 60
        case (.monthly, .medium): return 100
        case (.monthly, .hard):   return 150
        default:                  return 15
        }
    }

    var gold: Int { exp / 3 }

    mutating func markCompleted() {
        isDone = true
        lastCompleted = Date()
    }
}

// MARK: - Statystyki dzienne
struct DailyStats: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var date: Date
    var tasksCompleted: Int
    var expEarned: Int
    var goldEarned: Int = 0
    var hpLost: Int = 0
}

// MARK: - Historia tygodnia
struct WeekHistory: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var weekNumber: Int
    var startDate: Date
    var tasksCompleted: Int
    var expEarned: Int
    var goldEarned: Int = 0
    var penaltiesCount: Int = 0
}

// MARK: - Osiągnięcia
struct Achievement: Identifiable, Codable, Equatable, Sendable {
    var id: String
    var title: String
    var description: String
    var icon: String
    var isUnlocked: Bool = false
    var unlockedDate: Date? = nil
    var color: String
    var xpReward: Int = 0

    static let all: [Achievement] = [
        Achievement(id: "first_task",      title: "Pierwsza krew",      description: "Ukończ pierwsze zadanie",              icon: "drop.fill",                  color: "red",    xpReward: 10),
        Achievement(id: "tasks_50",        title: "Pracuś",             description: "Ukończ łącznie 50 zadań",              icon: "checkmark.seal.fill",         color: "green",  xpReward: 50),
        Achievement(id: "tasks_100",       title: "Weteran",            description: "Ukończ łącznie 100 zadań",             icon: "medal.fill",                  color: "orange", xpReward: 100),
        Achievement(id: "tasks_250",       title: "Legenda",            description: "Ukończ łącznie 250 zadań",             icon: "crown.fill",                  color: "yellow", xpReward: 250),
        Achievement(id: "streak_4",        title: "Regularny",          description: "Utrzymaj serię przez 4 tygodnie",      icon: "calendar.badge.checkmark",    color: "blue",   xpReward: 40),
        Achievement(id: "streak_7",        title: "Tygodniowiec",       description: "Utrzymaj serię przez 7 tygodni",       icon: "flame.fill",                  color: "orange", xpReward: 70),
        Achievement(id: "streak_12",       title: "Niezłomny",          description: "Utrzymaj serię przez 12 tygodni",      icon: "bolt.shield.fill",            color: "purple", xpReward: 120),
        Achievement(id: "level_5",         title: "Adept",              description: "Osiągnij poziom 5",                   icon: "star.fill",                   color: "teal",   xpReward: 50),
        Achievement(id: "master",          title: "Mistrz Czystości",   description: "Osiągnij poziom MAX",                 icon: "trophy.fill",                 color: "yellow", xpReward: 200),
        Achievement(id: "kitchen_20",      title: "Kucharz",            description: "Ukończ 20 zadań w Kuchni",             icon: "fork.knife",                  color: "orange", xpReward: 30),
        Achievement(id: "bathroom_20",     title: "Czysta łazienka",    description: "Ukończ 20 zadań w Łazience",           icon: "shower.fill",                 color: "blue",   xpReward: 30),
        Achievement(id: "all_weekly",      title: "Perfekcjonista",     description: "Ukończ 100% zadań tygodniowych",       icon: "star.fill",                   color: "yellow", xpReward: 75),
        Achievement(id: "all_monthly",     title: "Miesięcznik",        description: "Ukończ wszystkie zadania miesięczne",  icon: "calendar",                    color: "purple", xpReward: 100),
        Achievement(id: "gold_500",        title: "Bogacz",             description: "Zgromadź łącznie 500 złota",           icon: "dollarsign.circle.fill",      color: "yellow", xpReward: 50),
        Achievement(id: "gold_2000",       title: "Milioner",           description: "Zgromadź łącznie 2000 złota",          icon: "banknote.fill",               color: "green",  xpReward: 150),
        Achievement(id: "shop_first",      title: "Shopaholic",         description: "Kup pierwszą nagrodę w sklepie",       icon: "bag.fill",                    color: "purple", xpReward: 20),
        Achievement(id: "challenge_5",     title: "Wyzwaniowiec",       description: "Ukończ 5 wyzwań tygodniowych",         icon: "bolt.fill",                   color: "teal",   xpReward: 60),
        Achievement(id: "custom_task",     title: "Twórca",             description: "Dodaj własne zadanie",                icon: "plus.circle.fill",            color: "pink",   xpReward: 15),
        Achievement(id: "first_pet",       title: "Pierwszy pupil",     description: "Kup pierwszego peta",                 icon: "pawprint.fill",               color: "pink",   xpReward: 30),
        Achievement(id: "pet_master",      title: "Pet Master",         description: "Podnieś peta na poziom 5",            icon: "crown.fill",                  color: "yellow", xpReward: 80),
        Achievement(id: "pet_collector",   title: "Kolekcjoner",        description: "Miej 3 różne pety",                   icon: "pawprint.circle.fill",        color: "pink",   xpReward: 60),
        Achievement(id: "stats_max",       title: "Staty max",          description: "Maxuj jedną statystykę do 10",        icon: "chart.bar.fill",              color: "blue",   xpReward: 100),
        Achievement(id: "skill_master",    title: "Skill Master",       description: "Odblokuj 3 skille",                   icon: "sparkles",                    color: "yellow", xpReward: 80),
        Achievement(id: "inventory_full",  title: "Full Inventory",     description: "5 przedmiotów w ekwipunku",            icon: "bag.circle.fill",             color: "purple", xpReward: 40),
        Achievement(id: "health_hero",     title: "Health Hero",        description: "Ukończ 20 zadań Zdrowie",             icon: "heart.fill",                  color: "red",    xpReward: 40),
        Achievement(id: "fitness_freak",   title: "Fitness Freak",      description: "Ukończ 7 zadań Fitness z rzędu",       icon: "figure.walk",                 color: "mint",   xpReward: 70),
        Achievement(id: "focus_god",       title: "Focus God",          description: "Ukończ 25 sesji Pomodoro",            icon: "brain.head.profile",          color: "teal",   xpReward: 80),
        Achievement(id: "water_week",      title: "Wodopój",            description: "Pij wodę 7 dni z rzędu",              icon: "drop.circle.fill",            color: "blue",   xpReward: 50),
        Achievement(id: "selfcare_10",     title: "Self Care",          description: "Ukończ 10 zadań Dbania o siebie",     icon: "figure.mind.and.body",        color: "pink",   xpReward: 40),
        Achievement(id: "finance_first",   title: "Finansista",         description: "Ukończ pierwsze zadanie Finanse",      icon: "banknote.fill",               color: "green",  xpReward: 20),
        Achievement(id: "social_10",       title: "Socialite",          description: "Ukończ 10 zadań Społecznych",         icon: "bubble.left.fill",            color: "cyan",   xpReward: 40),
        Achievement(id: "work_20",         title: "Pracownik miesiąca", description: "Ukończ 20 zadań Praca/Nauka",         icon: "pencil.and.list.clipboard",   color: "orange", xpReward: 60),
        Achievement(id: "no_penalty_week", title: "Bez kar",            description: "Tydzień bez utraty HP",               icon: "shield.fill",                 color: "green",  xpReward: 50),
        Achievement(id: "hp_full_month",   title: "HP Full Month",      description: "Miesiąc z pełnym HP",                 icon: "heart.circle.fill",           color: "red",    xpReward: 100),
        Achievement(id: "daily_reset_30",  title: "Daily Master",       description: "30 dni perfekcyjnych daily",          icon: "sun.max.fill",                color: "orange", xpReward: 150),
        Achievement(id: "combo_5",         title: "Combo x5",           description: "Ukończ 5 zadań w ciągu godziny",       icon: "bolt.circle.fill",            color: "orange", xpReward: 50),
        Achievement(id: "combo_10",        title: "Combo x10",          description: "Ukończ 10 zadań w ciągu godziny",      icon: "flame.circle.fill",           color: "red",    xpReward: 100),
        Achievement(id: "explorer",        title: "Odkrywca",           description: "Pet wrócił z wyprawy",                icon: "map.fill",                    color: "blue",   xpReward: 40),
        Achievement(id: "avatar_dressed",  title: "Modny Gracz",        description: "Załóż 3 elementy ubrania na awatara", icon: "tshirt.fill",                 color: "pink",   xpReward: 30),
        Achievement(id: "avatar_crown",    title: "Król/Królowa",       description: "Kup i załóż Koronę",                  icon: "crown.fill",                  color: "yellow", xpReward: 80),
    ]
}

// MARK: - Avatar System
enum AvatarLayer: String, Codable, CaseIterable, Sendable {
    case body      = "Ciało"
    case hair      = "Włosy"
    case shirt     = "Koszulka"
    case pants     = "Spodnie"
    case shoes     = "Buty"
    case hat       = "Nakrycie głowy"
    case accessory = "Akcesoria"
}

struct AvatarItem: Codable, Identifiable, Equatable, Sendable {
    var id: UUID = UUID()
    var name: String
    var layer: AvatarLayer
    var symbol: String
    var colorName: String
    var shopItemId: UUID?

    var swiftUIColor: Color {
        switch colorName {
        case "red":    return .red
        case "blue":   return .blue
        case "green":  return .green
        case "yellow": return .yellow
        case "purple": return .purple
        case "orange": return .orange
        case "pink":   return .pink
        case "brown":  return Color(red: 0.6, green: 0.4, blue: 0.2)
        case "black":  return Color(.label)
        case "white":  return Color(.systemBackground)
        default:       return .gray
        }
    }
}

// MARK: - Avatar Shop IDs (stałe UUID)
enum AvatarShopIDs {
    static let blueShirt   = UUID(uuidString: "A0000001-0000-0000-0000-000000000001")!
    static let redShirt    = UUID(uuidString: "A0000001-0000-0000-0000-000000000002")!
    static let purpleShirt = UUID(uuidString: "A0000001-0000-0000-0000-000000000003")!
    static let blackPants  = UUID(uuidString: "A0000001-0000-0000-0000-000000000004")!
    static let blueJeans   = UUID(uuidString: "A0000001-0000-0000-0000-000000000005")!
    static let whiteShoes  = UUID(uuidString: "A0000001-0000-0000-0000-000000000006")!
    static let redShoes    = UUID(uuidString: "A0000001-0000-0000-0000-000000000007")!
    static let cap         = UUID(uuidString: "A0000001-0000-0000-0000-000000000008")!
    static let crown       = UUID(uuidString: "A0000001-0000-0000-0000-000000000009")!
    static let glasses     = UUID(uuidString: "A0000001-0000-0000-0000-000000000010")!
    static let sword       = UUID(uuidString: "A0000001-0000-0000-0000-000000000011")!
}

// MARK: - Shop Item
struct ShopItem: Identifiable, Codable, Equatable, Sendable {
    var id: UUID = UUID()
    var title: String
    var icon: String
    var cost: Int
    var isPurchased: Bool = false
    var isCustom: Bool = false
    var isConsumable: Bool = false
    var category: ShopCategory = .reward
    var description: String = ""

    init(id: UUID = UUID(), title: String, icon: String, cost: Int,
         isPurchased: Bool = false, isCustom: Bool = false,
         isConsumable: Bool = false, category: ShopCategory = .reward,
         description: String = "") {
        self.id = id
        self.title = title
        self.icon = icon
        self.cost = cost
        self.isPurchased = isPurchased
        self.isCustom = isCustom
        self.isConsumable = isConsumable
        self.category = category
        self.description = description
    }
}

enum ShopCategory: String, Codable, Sendable, CaseIterable {
    case reward = "Nagrody"
    case pet    = "Pety"
    case skill  = "Skille"
    case item   = "Przedmioty"
    case potion = "Eliksiry"
    case avatar = "Ubrania"
}

extension ShopItem {
    static let defaults: [ShopItem] = [

        // MARK: Nagrody
        ShopItem(title: "Odcinek serialu",           icon: "tv.fill",               cost: 50,  category: .reward,  description: "Zasłużony odpoczynek — jeden odcinek ulubionego serialu 📺"),
        ShopItem(title: "Kawa na mieście",            icon: "cup.and.saucer.fill",   cost: 80,  category: .reward,  description: "Wyjdź na kawę do ulubionej kawiarni ☕"),
        ShopItem(title: "Godzina grania",             icon: "gamecontroller.fill",   cost: 60,  category: .reward,  description: "Pełna godzina bez wyrzutów sumienia 🎮"),
        ShopItem(title: "Ulubiony deser",             icon: "birthday.cake.fill",    cost: 100, category: .reward,  description: "Zjedz cokolwiek słodkiego na co masz ochotę 🍰"),
        ShopItem(title: "Dzień bez sprzątania",       icon: "bed.double.fill",       cost: 200, category: .reward,  description: "Jeden dzień całkowitego odpoczynku 🛌"),
        ShopItem(title: "Pizza",                      icon: "flame.fill",            cost: 150, category: .reward,  description: "Zamów pizzę — w pełni zasłużoną 🍕"),
        ShopItem(title: "Nowa gra / film",            icon: "cart.fill",             cost: 300, category: .reward,  description: "Kup nową grę lub obejrzyj film w kinie 🎬"),
        ShopItem(title: "Noc filmowa",                icon: "popcorn.fill",          cost: 120, category: .reward,  description: "Wieczór z popcornem i ulubionym filmem 🍿"),
        ShopItem(title: "Wyjście do kina 🎬",          icon: "film.fill",             cost: 180, category: .reward,  description: "Seans w kinie — solo lub ze znajomymi 🎟️"),
        ShopItem(title: "Masaż/SPA 💆",               icon: "figure.mind.and.body",  cost: 250, category: .reward,  description: "Relaks i regeneracja — wizyta w SPA 💆"),
        ShopItem(title: "Nowe buty/ubranie 👟",       icon: "cart.badge.plus",       cost: 400, category: .reward,  description: "Kup sobie coś nowego 🛍️"),
        ShopItem(title: "Weekend bez obowiązków 🏖️",  icon: "sun.horizon.fill",      cost: 500, category: .reward,  description: "Cały weekend dla siebie 🌅"),
        ShopItem(title: "Ulubiona książka 📖",         icon: "book.fill",             cost: 120, category: .reward,  description: "Kup lub pożycz książkę 📚"),
        ShopItem(title: "Zdrowy posiłek na wynos 🥗", icon: "fork.knife.circle.fill",cost: 90,  category: .reward,  description: "Zamów zdrowy posiłek 🥡"),

        // MARK: Pety
        ShopItem(title: "Kot Sprzątacz 🐱",           icon: "pawprint.fill",         cost: 100, category: .pet,     description: "Daje +2 XP do każdego zadania ❤️"),
        ShopItem(title: "Pies Porządkowy 🐶",          icon: "pawprint.circle.fill",  cost: 150, category: .pet,     description: "Lojalny towarzysz — +3 XP 🐾"),
        ShopItem(title: "Sowa Mądrości 🦉",            icon: "bird.fill",             cost: 200, category: .pet,     description: "+4 XP za zadania Fokus 🦉"),
        ShopItem(title: "Smok Motywacji 🐉",           icon: "flame.circle.fill",     cost: 350, category: .pet,     description: "+7 XP per zadanie 🔥"),
        ShopItem(title: "Feniks Odrodzenia 🦅",        icon: "bird.fill",             cost: 500, category: .pet,     description: "Po śmierci HP odradza się do 50 ✨"),

        // MARK: Skille
        ShopItem(title: "TurboClean ⚡",               icon: "bolt.circle.fill",       cost: 200, category: .skill,   description: "+50% XP za każde zadanie ⚡"),
        ShopItem(title: "GoldRush 💰",                 icon: "dollarsign.circle.fill", cost: 250, category: .skill,   description: "+50% złota za każde zadanie 💰"),
        ShopItem(title: "FocusMaster 🧠",              icon: "brain.head.profile",     cost: 300, category: .skill,   description: "Focus Timer daje 30 XP zamiast 20 🧠"),
        ShopItem(title: "IronWill 🛡️",                icon: "shield.lefthalf.filled", cost: 300, category: .skill,   description: "Kary HP zmniejszone o 50% 🛡️"),
        ShopItem(title: "LuckyStrike 🍀",              icon: "4.circle.fill",          cost: 350, category: .skill,   description: "10% szansy na 3x XP 🍀"),

        // MARK: Przedmioty
        ShopItem(title: "Złoty Mop (+XP) ✨",          icon: "sparkles",              cost: 120, category: .item,    description: "+25% XP — załóż w ekwipunku ✨"),
        ShopItem(title: "Plecak Bohatera 🎒",          icon: "backpack.fill",         cost: 180, category: .item,    description: "Zwiększa pojemność ekwipunku 🎒"),
        ShopItem(title: "Zegar Fokusa ⏱️",             icon: "timer",                 cost: 150, category: .item,    description: "Każda sesja Focus Timer daje +10 XP ⏱️"),

        // MARK: Eliksiry
        ShopItem(title: "Potion HP ❤️",                icon: "heart.fill",             cost: 30,  isConsumable: true, category: .potion, description: "Przywraca 30 HP natychmiast ❤️"),
        ShopItem(title: "Eliksir HP Max ❤️‍🔥",          icon: "heart.circle.fill",      cost: 50,  isConsumable: true, category: .potion, description: "Przywraca HP do 100 natychmiast 🔴"),
        ShopItem(title: "Eliksir Streak 🔥",           icon: "flame.circle.fill",      cost: 100, isConsumable: true, category: .potion, description: "+1 tydzień do serii 🔥"),
        ShopItem(title: "Eliksir XP x2 🔮",            icon: "circle.hexagongrid.fill",cost: 80,  isConsumable: true, category: .potion, description: "2x XP przez 24 godziny 🔮"),
        ShopItem(title: "Złoty Eliksir 💛",            icon: "drop.circle.fill",       cost: 60,  isConsumable: true, category: .potion, description: "+50% złota przez 24h 💛"),

        // MARK: Ubrania awatara
        ShopItem(id: AvatarShopIDs.blueShirt,   title: "Niebieska bluza",    icon: "tshirt.fill",       cost: 80,  category: .avatar, description: "Niebieska bluza dla awatara 👕"),
        ShopItem(id: AvatarShopIDs.redShirt,    title: "Czerwona koszulka",  icon: "tshirt.fill",       cost: 80,  category: .avatar, description: "Czerwona koszulka dla awatara 👕"),
        ShopItem(id: AvatarShopIDs.purpleShirt, title: "Fioletowa bluza",    icon: "tshirt.fill",       cost: 100, category: .avatar, description: "Fioletowa bluza dla awatara 👕"),
        ShopItem(id: AvatarShopIDs.blackPants,  title: "Czarne spodnie",     icon: "figure.walk",       cost: 90,  category: .avatar, description: "Eleganckie czarne spodnie 👖"),
        ShopItem(id: AvatarShopIDs.blueJeans,   title: "Niebieskie jeansy",  icon: "figure.walk",       cost: 90,  category: .avatar, description: "Klasyczne niebieskie jeansy 👖"),
        ShopItem(id: AvatarShopIDs.whiteShoes,  title: "Białe buty",         icon: "shoeprints.fill",   cost: 70,  category: .avatar, description: "Czyste białe buty 👟"),
        ShopItem(id: AvatarShopIDs.redShoes,    title: "Czerwone buty",      icon: "shoeprints.fill",   cost: 70,  category: .avatar, description: "Czerwone buty 👟"),
        ShopItem(id: AvatarShopIDs.cap,         title: "Czapka z daszkiem",  icon: "baseball.fill",     cost: 60,  category: .avatar, description: "Klasyczna czapka 🧢"),
        ShopItem(id: AvatarShopIDs.crown,       title: "Korona 👑",           icon: "crown.fill",        cost: 500, category: .avatar, description: "Legendarny dodatek dla najlepszych 👑"),
        ShopItem(id: AvatarShopIDs.glasses,     title: "Okulary",            icon: "eyeglasses",        cost: 50,  category: .avatar, description: "Stylowe okulary 🕶️"),
        ShopItem(id: AvatarShopIDs.sword,       title: "Trofeum",            icon: "trophy.fill",       cost: 200, category: .avatar, description: "Akcesoria dla championów 🏆"),
    ]
}

// MARK: - Klasa gracza
enum PlayerClass: String, Codable, Sendable, CaseIterable {
    case warrior = "Wojownik"
    case mage    = "Mag"
    case rogue   = "Łotrzyk"
    case cleric  = "Kapłan"
    case ranger  = "Leśniczy"

    var icon: String {
        switch self {
        case .warrior: return "⚔️"
        case .mage:    return "🧙"
        case .rogue:   return "🗡️"
        case .cleric:  return "✝️"
        case .ranger:  return "🏹"
        }
    }

    var description: String {
        switch self {
        case .warrior: return "+20% XP za kuchnię i fitness"
        case .mage:    return "+30% XP za fokus i sypialnię"
        case .rogue:   return "15% szansa na double gold"
        case .cleric:  return "HP regen za zdrowie, -kary"
        case .ranger:  return "+10% do wszystkiego przy streak ≥3"
        }
    }

    var bonusStat: PlayerStat {
        switch self {
        case .warrior: return .strength
        case .mage:    return .intelligence
        case .rogue:   return .dexterity
        case .cleric:  return .willpower
        case .ranger:  return .perception
        }
    }
}

// MARK: - Profil gracza
struct PlayerProfile: Codable, Sendable {
    var name: String = "Sprzątacz"
    var bio: String = ""
    var avatarEmoji: String = "🧹"
    var accentColorName: String = "blue"
    var selectedTitle: String? = nil

    var totalTasksCompleted: Int  = 0
    var totalGoldEarned: Int      = 0
    var challengesCompleted: Int  = 0
    var kitchenTasksCompleted: Int  = 0
    var bathroomTasksCompleted: Int = 0
    var healthTasksCompleted: Int   = 0
    var fitnessTasksCompleted: Int  = 0
    var focusTasksCompleted: Int    = 0
    var financeTasksCompleted: Int  = 0
    var socialTasksCompleted: Int   = 0
    var selfcareTasksCompleted: Int = 0
    var workTasksCompleted: Int     = 0
    var longestStreak: Int          = 0
    var consecutiveDailyDays: Int   = 0
    var totalHPLost: Int            = 0

    var last7DaysActivity: [Bool] = Array(repeating: false, count: 7)
    var showcaseItems: [String]   = []

    var stats: [PlayerStat: Int] = [
        .strength: 1, .intelligence: 1,
        .dexterity: 1, .perception: 1,
        .willpower: 1, .charisma: 1
    ]

    var pointsToAllocate: Int       = 0
    var inventory: [InventoryItem]  = []
    var pets: [Pet]                 = []
    var playerClass: PlayerClass    = .warrior
    var skills: Set<String>         = []

    var xpBoostActive: Bool    = false
    var xpBoostExpiry: Date?   = nil
    var dailyWheelLastSpin: Date? = nil
    var activeBoosts: [String: Date] = [:]
    var focusSessions: [FocusSession] = []
    var moodHistory: [MoodLevel]   = []
    var chaosBusterMode: Bool      = false

    // MARK: - Avatar
    var equippedAvatar: [AvatarLayer: AvatarItem] = [
        .body:  AvatarItem(name: "Ciało",          layer: .body,  symbol: "person.fill", colorName: "brown"),
        .shirt: AvatarItem(name: "Biała koszulka", layer: .shirt, symbol: "tshirt.fill", colorName: "white")
    ]

    // MARK: Tytuły
    var displayTitle: String { selectedTitle ?? earnedTitle }

    var earnedTitle: String {
        switch totalTasksCompleted {
        case 0..<5:    return "Nowicjusz"
        case 5..<20:   return "Pomocnik"
        case 20..<50:  return "Sprzątacz"
        case 50..<100: return "Weteran"
        case 100..<250:return "Mistrz"
        default:       return "Legenda"
        }
    }

    var title: String { earnedTitle }

    var unlockedTitles: [String] {
        var titles: [String] = ["Nowicjusz"]
        if totalTasksCompleted >= 5   { titles.append("Pomocnik") }
        if totalTasksCompleted >= 20  { titles.append("Sprzątacz") }
        if totalTasksCompleted >= 50  { titles.append("Weteran") }
        if totalTasksCompleted >= 100 { titles.append("Mistrz") }
        if totalTasksCompleted >= 250 { titles.append("Legenda") }
        if healthTasksCompleted >= 20  { titles.append("Wodopój 💧") }
        if focusTasksCompleted >= 25   { titles.append("Fokusiarz 🧠") }
        if !pets.isEmpty               { titles.append("Pet Daddy 🐾") }
        if fitnessTasksCompleted >= 10 { titles.append("Sportowiec 🏃") }
        if financeTasksCompleted >= 5  { titles.append("Finansista 💰") }
        if skills.count >= 3           { titles.append("Skill Master ⚡") }
        return Array(Set(titles)).sorted()
    }

    var isXPBoostActive: Bool {
        guard xpBoostActive, let expiry = xpBoostExpiry else { return false }
        return Date() < expiry
    }
    var hasActiveDoubleXP: Bool {
        guard let expiry = activeBoosts["doubleXP"] else { return false }
        return Date() < expiry
    }
    var hasActiveGoldBoost: Bool {
        guard let expiry = activeBoosts["goldBoost"] else { return false }
        return Date() < expiry
    }
    var hasSkipPenalty: Bool {
        guard let expiry = activeBoosts["skipPenalty"] else { return false }
        return Date() < expiry
    }

    static func frameColor(for level: Int) -> String {
        switch level {
        case 1..<3:  return "gray"
        case 3..<5:  return "orange"
        case 5..<7:  return "blue"
        case 7..<10: return "yellow"
        default:     return "purple"
        }
    }

    var favoriteCategory: TaskCategory? {
        let counts: [(TaskCategory, Int)] = [
            (.kitchen,  kitchenTasksCompleted),
            (.bathroom, bathroomTasksCompleted),
            (.health,   healthTasksCompleted),
            (.fitness,  fitnessTasksCompleted),
            (.focus,    focusTasksCompleted),
            (.finance,  financeTasksCompleted),
            (.social,   socialTasksCompleted),
            (.selfcare, selfcareTasksCompleted),
            (.work,     workTasksCompleted),
        ]
        return counts.max(by: { $0.1 < $1.1 }).flatMap { $0.1 > 0 ? $0.0 : nil }
    }

    mutating func increment(category: TaskCategory) {
        switch category {
        case .kitchen:  kitchenTasksCompleted += 1
        case .bathroom: bathroomTasksCompleted += 1
        case .health:   healthTasksCompleted += 1
        case .fitness:  fitnessTasksCompleted += 1
        case .focus:    focusTasksCompleted += 1
        case .finance:  financeTasksCompleted += 1
        case .social:   socialTasksCompleted += 1
        case .selfcare: selfcareTasksCompleted += 1
        case .work:     workTasksCompleted += 1
        default: break
        }
        totalTasksCompleted += 1
    }
}

// MARK: - Wyzwanie tygodniowe
struct WeeklyChallenge: Codable, Sendable {
    var category: TaskCategory
    var targetCount: Int
    var currentCount: Int   = 0
    var bonusXPMultiplier: Double = 1.5
    var weekNumber: Int
    var bonusGold: Int      = 50
    var isCompleted: Bool   { currentCount >= targetCount }

    var description: String {
        "Ukończ \(targetCount) zadań z kategorii \(category.rawValue)"
    }

    static func generate(for weekNumber: Int) -> WeeklyChallenge {
        let categories: [TaskCategory] = [
            .kitchen, .bathroom, .living, .bedroom, .general,
            .health, .fitness, .focus, .finance, .social, .selfcare, .work
        ]
        let idx       = weekNumber % categories.count
        let target    = 3 + (weekNumber % 4)
        let bonusGold = 30 + (weekNumber % 5) * 10
        return WeeklyChallenge(
            category: categories[idx],
            targetCount: target,
            weekNumber: weekNumber,
            bonusGold: bonusGold
        )
    }
}

// MARK: - Date helpers
extension Date {
    var isToday: Bool { Calendar.current.isDateInToday(self) }
}

// MARK: - Domyślne zadania
extension CleaningTask {
    static let defaults: [CleaningTask] = [

        // DAILY — KUCHNIA
        CleaningTask(title: "Umyj naczynia",            category: .kitchen,  difficulty: .easy,   frequency: .daily),
        CleaningTask(title: "Wytrzyj blaty",            category: .kitchen,  difficulty: .easy,   frequency: .daily),
        CleaningTask(title: "Opróżnij zmywarkę",        category: .kitchen,  difficulty: .easy,   frequency: .daily),
        // DAILY — SYPIALNIA
        CleaningTask(title: "Posłanie łóżka",           category: .bedroom,  difficulty: .easy,   frequency: .daily),
        // DAILY — OGÓLNE
        CleaningTask(title: "Wynieś śmieci",            category: .general,  difficulty: .easy,   frequency: .daily),
        CleaningTask(title: "Posprzątaj przedpokój",    category: .general,  difficulty: .medium, frequency: .daily),
        // DAILY — ŁAZIENKA
        CleaningTask(title: "Wytrzyj lustro",           category: .bathroom, difficulty: .easy,   frequency: .daily),
        // DAILY — ZDROWIE
        CleaningTask(title: "Wypij 2L wody",            category: .health,   difficulty: .easy,   frequency: .daily),
        CleaningTask(title: "Zażyj leki/witaminy",      category: .health,   difficulty: .easy,   frequency: .daily),
        CleaningTask(title: "Śpij 7–8 godz.",           category: .health,   difficulty: .medium, frequency: .daily),
        // DAILY — FITNESS
        CleaningTask(title: "10k kroków (spacer)",      category: .fitness,  difficulty: .medium, frequency: .daily),
        CleaningTask(title: "5 min rozciągania",        category: .fitness,  difficulty: .easy,   frequency: .daily),
        // DAILY — FOKUS
        CleaningTask(title: "Lista zadań na dziś",      category: .focus,    difficulty: .easy,   frequency: .daily),
        CleaningTask(title: "Przerwa Pomodoro",         category: .focus,    difficulty: .easy,   frequency: .daily),
        CleaningTask(title: "5 min medytacji",          category: .focus,    difficulty: .easy,   frequency: .daily),
        CleaningTask(title: "Przegląd kalendarza",      category: .focus,    difficulty: .easy,   frequency: .daily),
        // DAILY — SPOŁECZNE
        CleaningTask(title: "Odpisz na wiadomości",     category: .social,   difficulty: .medium, frequency: .daily),
        // DAILY — DBANIE O SIEBIE
        CleaningTask(title: "Weź prysznic",             category: .selfcare, difficulty: .easy,   frequency: .daily),
        CleaningTask(title: "Umyj zęby (rano+wieczór)", category: .selfcare, difficulty: .easy,   frequency: .daily),
        // DAILY — PRACA/NAUKA
        CleaningTask(title: "30 min nauki/projektu",    category: .work,     difficulty: .medium, frequency: .daily),
        CleaningTask(title: "Sprawdź emaile",           category: .work,     difficulty: .easy,   frequency: .daily),
        // DAILY — FINANSE
        CleaningTask(title: "Sprawdź wydatki dnia",     category: .finance,  difficulty: .easy,   frequency: .daily),

        // WEEKLY
        CleaningTask(title: "Wyczyść kuchenkę",                    category: .kitchen,  difficulty: .medium, frequency: .weekly),
        CleaningTask(title: "Wyczyść lodówkę z przeterminowanych", category: .kitchen,  difficulty: .easy,   frequency: .weekly),
        CleaningTask(title: "Zaplanuj posiłki na tydzień",         category: .kitchen,  difficulty: .easy,   frequency: .weekly),
        CleaningTask(title: "Wyczyść toaletę",                     category: .bathroom, difficulty: .medium, frequency: .weekly),
        CleaningTask(title: "Wyczyść prysznic",                    category: .bathroom, difficulty: .medium, frequency: .weekly),
        CleaningTask(title: "Umyj podłogę w łazience",             category: .bathroom, difficulty: .easy,   frequency: .weekly),
        CleaningTask(title: "Odkurz salon",                        category: .living,   difficulty: .medium, frequency: .weekly),
        CleaningTask(title: "Wytrzyj kurze",                       category: .living,   difficulty: .easy,   frequency: .weekly),
        CleaningTask(title: "Zmień pościel",                       category: .bedroom,  difficulty: .medium, frequency: .weekly),
        CleaningTask(title: "Odkurz sypialnię",                    category: .bedroom,  difficulty: .easy,   frequency: .weekly),
        CleaningTask(title: "Umyj podłogi",                        category: .general,  difficulty: .medium, frequency: .weekly),
        CleaningTask(title: "Zrób pranie",                         category: .general,  difficulty: .easy,   frequency: .weekly),
        CleaningTask(title: "Złóż pranie",                         category: .general,  difficulty: .easy,   frequency: .weekly),
        CleaningTask(title: "Uzupełnij leki/suplementy",           category: .health,   difficulty: .easy,   frequency: .weekly),
        CleaningTask(title: "Sprawdź swój nastrój (journal)",      category: .health,   difficulty: .easy,   frequency: .weekly),
        CleaningTask(title: "Bieg/ćwiczenia 30 min",               category: .fitness,  difficulty: .hard,   frequency: .weekly),
        CleaningTask(title: "Basen / rower / joga",                category: .fitness,  difficulty: .medium, frequency: .weekly),
        CleaningTask(title: "Przegląd tygodnia (weekly review)",   category: .focus,    difficulty: .medium, frequency: .weekly),
        CleaningTask(title: "Wyczyść skrzynkę mailową",            category: .focus,    difficulty: .medium, frequency: .weekly),
        CleaningTask(title: "Zaplanuj spotkanie ze znajomymi",     category: .social,   difficulty: .medium, frequency: .weekly),
        CleaningTask(title: "Przejrzyj wydatki tygodnia",          category: .finance,  difficulty: .easy,   frequency: .weekly),
        CleaningTask(title: "Sprawdź rachunki do zapłacenia",      category: .finance,  difficulty: .medium, frequency: .weekly),
        CleaningTask(title: "Zrób pedicure/manicure",              category: .selfcare, difficulty: .easy,   frequency: .weekly),
        CleaningTask(title: "Wyczyść portfel/torebkę",             category: .selfcare, difficulty: .easy,   frequency: .weekly),
        CleaningTask(title: "Zaplanuj priorytety na nowy tydzień", category: .work,     difficulty: .medium, frequency: .weekly),
        CleaningTask(title: "Ukończ jeden kurs/lekcję online",     category: .work,     difficulty: .hard,   frequency: .weekly),

        // MONTHLY
        CleaningTask(title: "Wyczyść lodówkę",                         category: .kitchen,  difficulty: .hard,   frequency: .monthly),
        CleaningTask(title: "Wyczyść piekarnik",                        category: .kitchen,  difficulty: .hard,   frequency: .monthly),
        CleaningTask(title: "Umyj okna",                               category: .living,   difficulty: .hard,   frequency: .monthly),
        CleaningTask(title: "Wyczyść fugi w łazience",                 category: .bathroom, difficulty: .hard,   frequency: .monthly),
        CleaningTask(title: "Umyj kaloryfery",                         category: .general,  difficulty: .medium, frequency: .monthly),
        CleaningTask(title: "Przetrzyj listwy i ramy",                 category: .general,  difficulty: .medium, frequency: .monthly),
        CleaningTask(title: "Przejrzyj ubrania (oddaj niepotrzebne)",  category: .bedroom,  difficulty: .hard,   frequency: .monthly),
        CleaningTask(title: "Przejrzyj subskrypcje",                   category: .finance,  difficulty: .medium, frequency: .monthly),
        CleaningTask(title: "Zrób bilans budżetu",                     category: .finance,  difficulty: .hard,   frequency: .monthly),
        CleaningTask(title: "Wizyta u lekarza/dentysta",               category: .health,   difficulty: .hard,   frequency: .monthly),
        CleaningTask(title: "Backup danych na komputerze",             category: .work,     difficulty: .medium, frequency: .monthly),
        CleaningTask(title: "Wyczyść aplikacje i pliki na telefonie",  category: .focus,    difficulty: .medium, frequency: .monthly),
    ]
}

// MARK: - Sync Payload
struct SyncPayload: Codable, Sendable {
    var tasks: [CleaningTask]
    var experience: Int
    var streak: Int
    var gold: Int
    var playerHP: Int
    var lastResetDate: Date
    var lastDailyReset: Date
    var dailyStats: [DailyStats]
    var weekHistory: [WeekHistory]
    var achievements: [Achievement]
    var shopItems: [ShopItem]
    var profile: PlayerProfile
    var weeklyChallenge: WeeklyChallenge?
}
