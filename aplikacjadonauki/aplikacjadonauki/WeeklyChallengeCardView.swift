import SwiftUI

// MARK: - WeeklyChallengeCardView
struct WeeklyChallengeCardView: View {
    let challenge: WeeklyChallenge

    private var progress: Double {
        min(1.0, Double(challenge.currentCount) / Double(max(challenge.targetCount, 1)))
    }
    private var bonusXPText: String { "+\(Int((challenge.bonusXPMultiplier - 1) * 100))% XP" }
    private var categoryColor: Color { challenge.category.swiftUIColor }
    private var daysLeft: Int {
        let cal = Calendar.current
        let end = cal.nextDate(after: Date(),
                               matching: DateComponents(weekday: 2),
                               matchingPolicy: .nextTimePreservingSmallerComponents)
                  ?? Date().addingTimeInterval(7 * 86400)
        return max(0, cal.dateComponents([.day], from: Date(), to: end).day ?? 0)
    }
    private var difficulty: TaskDifficulty {
        switch challenge.targetCount {
        case ..<5: return .easy
        case ..<10: return .medium
        default: return .hard
        }
    }
    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    private var urgencyColor: Color {
        daysLeft <= 1 ? .red : daysLeft <= 3 ? .orange : .teal
    }

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // — Kolorowy top-strip z gradientem
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.18))
                        .frame(width: 40, height: 40)
                    Image(systemName: challenge.category.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(categoryColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Wyzwanie tygodnia")
                        .font(.caption).bold()
                        .foregroundStyle(.secondary)
                    Text(challenge.description)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
                Spacer()
                if challenge.isCompleted {
                    Label("Ukończone!", systemImage: "checkmark.seal.fill")
                        .font(.caption).bold()
                        .foregroundColor(.green)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().fill(Color.green.opacity(0.13)))
                } else {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(bonusXPText)
                            .font(.caption).bold()
                            .foregroundColor(categoryColor)
                            .padding(.horizontal, 9).padding(.vertical, 4)
                            .background(Capsule().fill(categoryColor.opacity(0.12)))
                        HStack(spacing: 3) {
                            Text(difficulty.icon)
                            Text(difficulty.rawValue)
                        }
                        .font(.caption2).bold()
                        .foregroundColor(difficultyColor)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(difficultyColor.opacity(0.10)))
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)

            Divider().padding(.horizontal, 14)

            // — Nagrody + czas
            HStack(spacing: 8) {
                // Gold reward
                HStack(spacing: 3) {
                    Image(systemName: "dollarsign.circle.fill").font(.caption2).foregroundColor(.yellow)
                    Text("+\(challenge.bonusGold) gold").font(.caption2).bold().foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Capsule().fill(Color.yellow.opacity(0.10)))

                // XP reward
                HStack(spacing: 3) {
                    Image(systemName: "bolt.fill").font(.caption2).foregroundColor(categoryColor)
                    Text(bonusXPText).font(.caption2).bold().foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Capsule().fill(categoryColor.opacity(0.08)))

                Spacer()

                // Dni + czas
                if !challenge.isCompleted {
                    HStack(spacing: 3) {
                        Image(systemName: "clock.fill").font(.caption2).foregroundColor(urgencyColor)
                        Text(daysLeft == 0 ? "Dziś koniec!" : "\(daysLeft) \(daysLeft == 1 ? "dzień" : "dni")")
                            .font(.caption2).bold()
                            .foregroundColor(urgencyColor)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(urgencyColor.opacity(0.10)))
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)

            Divider().padding(.horizontal, 14)

            // — Progress bar
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemFill))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(
                                colors: challenge.isCompleted
                                    ? [.green, .teal]
                                    : [categoryColor, categoryColor.opacity(0.65)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * animatedProgress, height: 8)
                            .animation(.spring(response: 0.65, dampingFraction: 0.75), value: animatedProgress)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("\(challenge.currentCount)/\(challenge.targetCount) zadań")
                        .font(.caption2).foregroundStyle(.secondary)
                    Spacer()
                    let remaining = challenge.targetCount - challenge.currentCount
                    if remaining > 0 && !challenge.isCompleted {
                        Text("Jeszcze \(remaining) \(remaining == 1 ? "zadanie" : "zadań")")
                            .font(.caption2).bold()
                            .foregroundColor(daysLeft <= 1 ? .red : categoryColor)
                    } else if challenge.isCompleted {
                        Text("🎉 Cel osiągnięty!").font(.caption2).bold().foregroundColor(.green)
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
                .shadow(color: (challenge.isCompleted ? Color.green : categoryColor).opacity(0.14), radius: 14, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(
                    LinearGradient(
                        colors: challenge.isCompleted
                            ? [.green.opacity(0.45), .teal.opacity(0.20)]
                            : [categoryColor.opacity(0.35), categoryColor.opacity(0.10)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ), lineWidth: 1.2
                )
        )
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.15)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { v in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { animatedProgress = v }
        }
    }
}
