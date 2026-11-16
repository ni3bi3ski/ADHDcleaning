import Foundation
import Combine
import SwiftUI

/// Ustawienia wyglądu zapisywane lokalnie. Współdzielona instancja: SettingsStore.shared.
class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    @Published var accentColorName: String {
        didSet { UserDefaults.standard.set(accentColorName, forKey: "accentColorName") }
    }

    init() {
        accentColorName = UserDefaults.standard.string(forKey: "accentColorName") ?? "Niebieski"
    }

    func colorFor(_ name: String) -> Color {
        switch name {
        case "Niebieski", "blue":      return .blue
        case "Fioletowy", "purple":    return .purple
        case "Różowy", "pink":        return .pink
        case "Czerwony", "red":        return .red
        case "Pomarańczowy", "orange": return .orange
        case "Żółty", "yellow":      return .yellow
        case "Zielony", "green":       return .green
        case "Miętowy", "mint":       return .mint
        case "Turkusowy", "teal":      return .teal
        case "Indygo", "indigo":       return .indigo
        default:                       return .blue
        }
    }
}
