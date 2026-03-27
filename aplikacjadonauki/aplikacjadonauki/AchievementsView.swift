import SwiftUI

struct AchievementsView: View {
    @ObservedObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    var unlockedCount: Int { vm.achievements.filter { $0.isUnlocked }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Postęp
                    VStack(spacing: 8) {
                        HStack {
                            Text("\(unlockedCount)/\(vm.achievements.count) odblokowanych")
                                .font(.subheadline).bold()
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(Double(unlockedCount) / Double(vm.achievements.count) * 100))%")
                                .font(.subheadline).bold()
                                .foregroundColor(.purple)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemFill))
                                    .frame(height: 10)
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading, endPoint: .trailing
                                    ))
                                    .frame(
                                        width: geo.size.width * (Double(unlockedCount) / Double(vm.achievements.count)),
                                        height: 10
                                    )
                                    .animation(.spring(response: 0.5), value: unlockedCount)
                            }
                        }
                        .frame(height: 10)
                    }
                    .padding(.horizontal)

                    // MARK: - Siatka osiągnięć
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(vm.achievements) { achievement in
                            AchievementCell(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Osiągnięcia")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Zamknij") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Kafelek osiągnięcia
struct AchievementCell: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked
                          ? LinearGradient(colors: [achievement.swiftUIColor, achievement.swiftUIColor.opacity(0.6)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [Color(.systemFill), Color(.systemFill)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)

                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .white : .secondary)
            }
            .shadow(
                color: achievement.isUnlocked ? achievement.swiftUIColor.opacity(0.4) : .clear,
                radius: 8, x: 0, y: 3
            )

            VStack(spacing: 3) {
                Text(achievement.title)
                    .font(.caption).bold()
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                Text(achievement.description)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                if let date = achievement.unlockedDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(achievement.swiftUIColor)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: achievement.isUnlocked
                        ? achievement.swiftUIColor.opacity(0.1)
                        : Color.black.opacity(0.04),
                        radius: 6, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    achievement.isUnlocked
                    ? achievement.swiftUIColor.opacity(0.3)
                    : Color.gray.opacity(0.1),
                    lineWidth: 1
                )
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}
