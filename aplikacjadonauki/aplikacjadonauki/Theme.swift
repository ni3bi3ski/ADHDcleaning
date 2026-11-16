import SwiftUI

extension View {
    func appCard(tint: Color? = nil) -> some View {
        self.padding(16)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color(.secondarySystemGroupedBackground)))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder((tint ?? Color.primary).opacity(tint == nil ? 0.06 : 0.28), lineWidth: 1))
    }
}

struct AppSectionHeader: View {
    let title: String
    var systemImage: String? = nil
    var trailing: String? = nil
    var body: some View {
        HStack(spacing: 8) {
            if let systemImage { Image(systemName: systemImage).foregroundStyle(Color.accentColor) }
            Text(title).font(.headline)
            Spacer()
            if let trailing {
                Text(trailing).font(.caption.bold()).foregroundStyle(.secondary)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(Color(.systemFill)))
            }
        }
    }
}

struct StatusChip: View {
    let text: String
    var icon: String? = nil
    var color: Color = .secondary
    var body: some View {
        HStack(spacing: 4) {
            if let icon { Image(systemName: icon) }
            Text(text).lineLimit(1)
        }
        .font(.caption.bold()).foregroundStyle(color)
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(Capsule().fill(color.opacity(0.14)))
    }
}

extension PlayerStat {
    var sfSymbol: String {
        switch self {
        case .strength: return "figure.strengthtraining.traditional"
        case .intelligence: return "brain.head.profile"
        case .dexterity: return "hand.raised.fill"
        case .perception: return "eye.fill"
        case .willpower: return "flame.fill"
        case .charisma: return "sparkles"
        }
    }
    var tintColor: Color {
        switch self {
        case .strength: return .red
        case .intelligence: return .blue
        case .dexterity: return .green
        case .perception: return .teal
        case .willpower: return .orange
        case .charisma: return .pink
        }
    }
}
