import SwiftUI

struct BadgesScrollView: View {
    let medals: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(medals, id: \.self) { medal in
                    BadgePillView(medal: medal)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Single Badge
private struct BadgePillView: View {
    let medal: String

    // Różne kolory dla różnych typów odznak
    var badgeStyle: (colors: [Color], icon: String) {
        if medal.contains("Mistrz")     { return ([.yellow, .orange, .red], "trophy.fill") }
        if medal.contains("Poziom")     { return ([.blue, .purple], "star.fill") }
        if medal.contains("Seria")      { return ([.orange, .red], "flame.fill") }
        if medal.contains("zadań") || medal.contains("zadanie") { return ([.green, .teal], "checkmark.seal.fill") }
        return ([.gray, .secondary], "medal.fill")
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: badgeStyle.icon)
                .font(.caption).bold()
                .foregroundStyle(
                    LinearGradient(
                        colors: badgeStyle.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(medal)
                .font(.caption).bold()
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color(.systemBackground))
                .shadow(color: badgeStyle.colors.first?.opacity(0.2) ?? .clear,
                        radius: 4, x: 0, y: 2)
        )
        .overlay(
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: badgeStyle.colors.map { $0.opacity(0.5) },
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}
