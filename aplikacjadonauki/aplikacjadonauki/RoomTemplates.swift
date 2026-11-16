import Foundation

struct TemplateTask {
    let title: String
    let category: TaskCategory
    let difficulty: TaskDifficulty
    let frequency: TaskFrequency
}

struct RoomTemplate: Identifiable {
    let id: String
    let name: String
    let icon: String
    let tasks: [TemplateTask]
}

extension RoomTemplate {
    static let all: [RoomTemplate] = [
        RoomTemplate(id: "kitchen", name: "Kuchnia", icon: "🍳", tasks: [
            TemplateTask(title: "Zmyj naczynia",        category: .kitchen, difficulty: .easy,   frequency: .daily),
            TemplateTask(title: "Wytrzyj blaty",        category: .kitchen, difficulty: .easy,   frequency: .daily),
            TemplateTask(title: "Wynieś śmieci",        category: .kitchen, difficulty: .easy,   frequency: .daily),
            TemplateTask(title: "Umyj kuchenkę",       category: .kitchen, difficulty: .medium, frequency: .weekly),
            TemplateTask(title: "Wyczyść lodówkę",      category: .kitchen, difficulty: .hard,   frequency: .monthly)
        ]),
        RoomTemplate(id: "bathroom", name: "Łazienka", icon: "🚿", tasks: [
            TemplateTask(title: "Przetrzyj umywalkę",  category: .bathroom, difficulty: .easy,   frequency: .daily),
            TemplateTask(title: "Umyj toaletę",       category: .bathroom, difficulty: .medium, frequency: .weekly),
            TemplateTask(title: "Umyj prysznic",        category: .bathroom, difficulty: .medium, frequency: .weekly),
            TemplateTask(title: "Wymień ręczniki",      category: .bathroom, difficulty: .easy,   frequency: .weekly)
        ]),
        RoomTemplate(id: "bedroom", name: "Sypialnia", icon: "🛏️", tasks: [
            TemplateTask(title: "Pościeł łóżko",          category: .bedroom, difficulty: .easy,   frequency: .daily),
            TemplateTask(title: "Zbierz ubrania z podłogi", category: .bedroom, difficulty: .easy, frequency: .daily),
            TemplateTask(title: "Zmień pościel",         category: .bedroom, difficulty: .medium, frequency: .weekly),
            TemplateTask(title: "Odkurz sypialnię",     category: .bedroom, difficulty: .medium, frequency: .weekly)
        ]),
        RoomTemplate(id: "living", name: "Salon", icon: "🛋️", tasks: [
            TemplateTask(title: "Odłóż rzeczy na miejsce", category: .living, difficulty: .easy,   frequency: .daily),
            TemplateTask(title: "Odkurz salon",          category: .living, difficulty: .medium, frequency: .weekly),
            TemplateTask(title: "Zetrzyj kurze",         category: .living, difficulty: .medium, frequency: .weekly)
        ]),
        RoomTemplate(id: "morning", name: "Poranna rutyna", icon: "☀️", tasks: [
            TemplateTask(title: "Wypij szklankę wody",    category: .health,   difficulty: .easy, frequency: .daily),
            TemplateTask(title: "Weź leki lub suplementy", category: .health,   difficulty: .easy, frequency: .daily),
            TemplateTask(title: "Prysznic i pielęgnacja", category: .selfcare, difficulty: .easy, frequency: .daily),
            TemplateTask(title: "5 minut planowania dnia", category: .focus,   difficulty: .easy, frequency: .daily)
        ])
    ]
}

extension AppViewModel {
    /// Dodaje zadania z szablonu, pomijając te o tej samej nazwie. Zwraca liczbę dodanych.
    @discardableResult
    func addTemplate(_ template: RoomTemplate) -> Int {
        let existing = Set(tasks.map { $0.title })
        var added = 0
        for item in template.tasks where !existing.contains(item.title) {
            addCustomTask(title: item.title,
                          category: item.category,
                          difficulty: item.difficulty,
                          frequency: item.frequency)
            added += 1
        }
        return added
    }
}
