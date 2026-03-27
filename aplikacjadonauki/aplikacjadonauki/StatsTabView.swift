import SwiftUI

struct StatsTabView: View {
    @ObservedObject var vm: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderCardView(
                        level: vm.level,
                        streak: vm.streak,
                        experience: vm.experience,
                        levelProgress: vm.levelProgress,
                        xpForNextLevel: vm.xpForNextLevel,
                        onShowStats: {}
                    )
                    .padding(.horizontal)

                    if vm.profile.pointsToAllocate > 0 {
                        allocateSection
                    }

                    statsGrid
                    classSection
                    skillsSection
                    weeklyHistorySection
                    focusSessionsSection
                }
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Statystyki")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Alokacja punktów
    private var allocateSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "plus.circle.fill").foregroundColor(.yellow)
                Text("\(vm.profile.pointsToAllocate) punkt(y) do rozdania!")
                    .font(.headline).bold()
                Spacer()
            }
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 3),
                spacing: 10
            ) {
                ForEach(PlayerStat.allCases, id: \.self) { stat in
                    Button { vm.allocatePoint(to: stat) } label: {
                        VStack(spacing: 4) {
                            Text(stat.icon).font(.title2)
                            Text(stat.rawValue)
                                .font(.caption2).bold()
                                .multilineTextAlignment(.center)
                            Text("+1").font(.caption2).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.1)))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .disabled(vm.profile.pointsToAllocate == 0)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.yellow.opacity(0.08)))
        .overlay(RoundedRectangle(cornerRadius: 16)
            .strokeBorder(Color.yellow.opacity(0.3), lineWidth: 1))
        .padding(.horizontal)
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Atrybuty").font(.headline).bold()
                .padding(.horizontal)
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 2),
                spacing: 12
            ) {
                ForEach(PlayerStat.allCases, id: \.self) { stat in
                    let value = vm.profile.stats[stat] ?? 1
                    VStack(spacing: 6) {
                        Text(stat.icon).font(.largeTitle)
                        Text(stat.rawValue).font(.subheadline).bold()
                        Text(stat.description)
                            .font(.caption2).foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Text("\(value)")
                            .font(.title2).bold().foregroundStyle(.tint)
                        ProgressView(value: Double(min(value, 10)), total: 10).tint(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Class
    private var classSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Klasa").font(.headline).bold()
            ForEach(PlayerClass.allCases, id: \.self) { cls in
                let isSelected = vm.profile.playerClass == cls
                Button { vm.profile.playerClass = cls } label: {
                    HStack(spacing: 12) {
                        Text(cls.icon).font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cls.rawValue).font(.subheadline).bold()
                            Text(cls.description).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemFill))
                    )
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isSelected ? Color.blue.opacity(0.4) : Color.clear, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Skills
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Odblokowane skille").font(.headline).bold()
            if vm.profile.skills.isEmpty {
                Text("Kup skille w Sklepie! ⚡")
                    .foregroundStyle(.secondary).font(.subheadline)
            } else {
                ForEach(Array(vm.profile.skills).sorted(), id: \.self) { skill in
                    HStack {
                        Image(systemName: "bolt.circle.fill").foregroundColor(.yellow)
                        Text(skill).font(.subheadline)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Weekly History
    private var weeklyHistorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Historia tygodni").font(.headline).bold()
            if vm.weekHistory.isEmpty {
                Text("Brak historii — graj dalej! 🚀")
                    .foregroundStyle(.secondary).font(.subheadline)
            } else {
                ForEach(vm.weekHistory.prefix(5)) { week in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tydzień \(week.weekNumber)")
                                .font(.subheadline).bold()
                            Text(week.startDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(week.tasksCompleted) zadań")
                                .font(.subheadline).bold()
                            Text("+\(week.expEarned) XP")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Focus Sessions
    private var focusSessionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Focus Timer").font(.headline).bold()
                Spacer()
                Button {
                    vm.focusTimerActive ? vm.stopFocusTimer() : vm.startFocusTimer()
                } label: {
                    Label(
                        vm.focusTimerActive ? "Stop" : "Start",
                        systemImage: vm.focusTimerActive ? "stop.fill" : "play.fill"
                    )
                    .font(.subheadline).bold()
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(Capsule().fill(vm.focusTimerActive
                                               ? Color.red.opacity(0.12)
                                               : Color.teal.opacity(0.12)))
                    .foregroundColor(vm.focusTimerActive ? .red : .teal)
                }
                .buttonStyle(.plain)
            }

            if vm.focusTimerActive {
                HStack {
                    Image(systemName: "timer").foregroundColor(.teal)
                    Text(formatDuration(vm.focusTimeElapsed))
                        .font(.title2).bold().monospacedDigit()
                        .foregroundColor(.teal)
                    Spacer()
                    Text("Fokusuj się! 🧠").font(.caption).foregroundStyle(.secondary)
                }
            }

            if !vm.profile.focusSessions.isEmpty {
                Text("\(vm.profile.focusSessions.count) sesji łącznie")
                    .font(.caption).foregroundStyle(.secondary)
                Text("Najdłuższa: \(formatDuration(vm.profile.focusSessions.map { $0.duration }.max() ?? 0))")
                    .font(.caption).foregroundStyle(.secondary)
            } else {
                Text("Brak sesji — zacznij timer!").font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    private func formatDuration(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
