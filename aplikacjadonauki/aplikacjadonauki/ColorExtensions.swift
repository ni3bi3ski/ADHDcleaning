import SwiftUI

extension Color {
    /// Appkowe kolory po nazwie (Achievement.color, TaskCategory.colorName)
    static func appColor(named name: String) -> Color {
        switch name {
        case "red":     return .red
        case "orange":  return .orange
        case "yellow":  return .yellow
        case "green":   return .green
        case "mint":    return .mint
        case "teal":    return .teal
        case "cyan":    return .cyan
        case "blue":    return .blue
        case "indigo":  return .indigo
        case "purple":  return .purple
        case "pink":    return .pink
        case "gray":    return .gray
        default:        return .accentColor
        }
    }

    /// Inicjalizator z hex
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        var value: UInt64 = 0
        guard scanner.scanHexInt64(&value) else { return nil }
        let r = Double((value >> 16) & 0xff) / 255.0
        let g = Double((value >> 8)  & 0xff) / 255.0
        let b = Double(value & 0xff)          / 255.0
        self = Color(red: r, green: g, blue: b)
    }
}

extension TaskFrequency {
    var swiftUIColor: Color {
        switch self {
        case .daily:   return Color.appColor(named: "orange")
        case .weekly:  return Color.appColor(named: "blue")
        case .monthly: return Color.appColor(named: "purple")
        }
    }
}

// NOWE – dla WeeklyChallengeCardView
extension TaskCategory {
    var swiftUIColor: Color {
        Color.appColor(named: colorName)
    }
}

extension Achievement {
    var swiftUIColor: Color {
        Color.appColor(named: color)
    }
}
