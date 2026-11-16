import SwiftUI
import Charts

struct StatsTabView: View {
    @ObservedObject var vm: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HeaderCardView(
                        level: vm.level,
                        streak: vm.streak,
                        experience: vm.experience,
                        levelProgress: vm.levelProgress,
                        xpForNextLevel: vm.xpForNextLevel,
                        onShowStats: {}
                    )

                    if vm.profile.pointsToAllocate > 0 {
                        allocateSection
                    }

                    attributesSection
                    classSection
                    skillsSection
                    weeklySection
                    focusSection
                }
                .frame(maxWidth: 640)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Statystyki")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Punkty do rozdania
    private var allocateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "Punkty do rozdania",
                systemImage: "plus.circle.fill",
                trailing: "\(vm.profile.pointsToAllocate)"
            )
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                spacing: 10
            ) {
                ForEach(PlayerStat.allCases, id: \.self) { stat in
                    Button {
                        Haptics.tap()
                        vm.allocatePoint(to: stat)
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: stat.sfSymbol)
                                .font(.title3)
                                .foregroundStyle(stat.tintColor)
                            Text(stat.rawValue)
                                .font(.caption.bold())
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                            Text("+1")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 78)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(stat.tintColor.opacity(0.12))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(vm.profile.pointsToAllocate == 0)
                }
            }
        }
        .appCard(tint: .yellow)
    }

    // MARK: - Atrybuty
    private var attributesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Atrybuty", systemImage: "chart.bar.fill")
            ForEach(PlayerStat.allCases, id: \.self) { stat in
                let value = vm.profile.stats[stat] ?? 1
                HStack(spacing: 12) {
                    Image(systemName: stat.sfSymbol)
                        .font(.title3)
                        .foregroundStyle(stat.tintColor)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(stat.tintColor.opacity(0.14)))
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(stat.rawValue).font(.subheadline.bold())
                            Spacer()
                            Text("\(value)").font(.headline.monospacedDigit())
                        }
                        ProgressView(value: Double(min(value, 10)), total: 10)
                            .tint(stat.tintColor)
                        Text(stat.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    // MARK: - Klasa
    private var classSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Klasa", systemImage: "shield.lefthalf.filled")
            ForEach(PlayerClass.allCases, id: \.self) { cls in
                let isSelected = vm.profile.playerClass == cls
                Button {
                    Haptics.tap()
                    vm.profile.playerClass = cls
                } label: {
                    HStack(spacing: 12) {
                        Text(cls.icon).font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cls.rawValue).font(.subheadline.bold())
                            Text(cls.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.5))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isSelected ? Color.accentColor.opacity(0.12) : Color(.systemFill))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(isSelected ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    // MARK: - Umiejętności
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(
                title: "Umiejętności",
                systemImage: "bolt.circle.fill",
                trailing: "\(vm.profile.skills.count)"
            )
            if vm.profile.skills.isEmpty {
                Text("Kup umiejętności w Sklepie, żeby zdobywać więcej XP i złota.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], spacing: 8) {
                    ForEach(Array(vm.profile.skills).sorted(), id: \.self) { skill in
                        StatusChip(text: skill, icon: "bolt.fill", color: .yellow)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    // MARK: - Historia tygodni
    private var weeklySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Historia tygodni", systemImage: "calendar")
            if vm.weekHistory.isEmpty {
                Text("Brak historii. Pierwszy wpis pojawi się po zakończeniu tygodnia.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                let recent = Array(vm.weekHistory.prefix(8).reversed())
                Chart(recent) { week in
                    BarMark(
                        x: .value("Tydzień", "T\(week.weekNumber)"),
                        y: .value("Zadania", week.tasksCompleted)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 140)

                ForEach(vm.weekHistory.prefix(5)) { week in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tydzień \(week.weekNumber)")
                                .font(.subheadline.bold())
                            Text(week.startDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(week.tasksCompleted) zadań")
                                .font(.subheadline.bold())
                            Text("+\(week.expEarned) XP")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    // MARK: - Focus Timer
    private var focusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Focus Timer", systemImage: "timer")

            HStack {
                Text(formatDuration(vm.focusTimerActive ? vm.focusTimeElapsed : 0))
                    .font(.system(size: 44, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(vm.focusTimerActive ? Color.teal : Color.primary)
                Spacer()
                Button {
                    Haptics.tap()
                    vm.focusTimerActive ? vm.stopFocusTimer() : vm.startFocusTimer()
                } label: {
                    Label(
                        vm.focusTimerActive ? "Stop" : "Start",
                        systemImage: vm.focusTimerActive ? "stop.fill" : "play.fill"
                    )
                    .font(.headline)
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(Capsule().fill(vm.focusTimerActive ? Color.red : Color.teal))
                }
                .buttonStyle(.plain)
            }

            if vm.profile.focusSessions.isEmpty {
                Text("Brak sesji. Po 10 minutach dostaniesz bonusowe XP.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 8) {
                    StatusChip(text: "\(vm.profile.focusSessions.count) sesji", icon: "checkmark.circle.fill", color: .teal)
                    StatusChip(
                        text: "Najdłuższa \(formatDuration(vm.profile.focusSessions.map { $0.duration }.max() ?? 0))",
                        icon: "trophy.fill",
                        color: .orange
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private func formatDuration(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
