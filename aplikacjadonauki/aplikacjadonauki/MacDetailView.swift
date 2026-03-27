import SwiftUI

struct MacDetailView: View {
    @ObservedObject var vm: AppViewModel
    @Binding var selectedFrequency: TaskFrequency?
    @State private var selectedCategory: TaskCategory? = nil
    @State private var showAddTask      = false
    @State private var showAchievements = false
    @State private var showShop         = false
    @State private var showProfile      = false

    var filteredTasks: [CleaningTask] {
        vm.tasks.filter { task in
            let freqMatch = selectedFrequency == nil || task.frequency == selectedFrequency
            let catMatch  = selectedCategory  == nil || task.category  == selectedCategory
            return freqMatch && catMatch
        }
    }

    private var title: String {
        selectedFrequency?.rawValue ?? "Wszystkie zadania"
    }

    private var doneCount: Int  { filteredTasks.filter { $0.isDone }.count }
    private var totalCount: Int { filteredTasks.count }

    var body: some View {
        VStack(spacing: 0) {
            bannersSection
            quickStartSection
            wheelAndChaosRow
            categoryFilterSection
            Divider()
            taskListSection
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(title)
        .navigationSubtitle("\(doneCount)/\(totalCount) ukończonych")
        .toolbar { toolbarContent }
        .animation(.easeInOut,                                    value: vm.showDailyPenaltyBanner)
        .animation(.easeInOut,                                    value: vm.showWeeklyResetBanner)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.showLevelUpBanner)
        .animation(.easeInOut,                                    value: vm.showAchievementBanner)
        .animation(.easeInOut,                                    value: vm.showChallengeCompletedBanner)
        .sheet(isPresented: $showAddTask)      { AddCustomTaskView(vm: vm) }
        .sheet(isPresented: $showAchievements) { AchievementsView(vm: vm) }
        .sheet(isPresented: $showShop)         { ShopView(vm: vm) }
        .sheet(isPresented: $showProfile)      { ProfileView(vm: vm) }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button { showProfile = true } label: {
                Label(vm.profile.avatarEmoji, systemImage: "person.circle.fill")
            }
            .help("Profil")

            Button { showAchievements = true } label: {
                Label("Osiągnięcia", systemImage: "trophy.fill")
            }
            .help("Osiągnięcia (\(vm.unlockedAchievements.count)/\(vm.achievements.count))")

            Button { showShop = true } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bag.fill")
                    Text("\(vm.gold) 🪙").font(.caption).bold()
                }
            }
            .help("Sklep")

            Divider()

            Button { vm.spinWheel() } label: {
                Label(
                    vm.hasSpunWheelToday ? "Koło ✓" : "Koło 🎡",
                    systemImage: "circle.grid.cross.fill"
                )
            }
            .disabled(vm.hasSpunWheelToday)
            .help(vm.hasSpunWheelToday ? "Koło obrócone dziś" : "Obróć Dzienne Koło")

            Divider()

            Button { showAddTask = true } label: {
                Label("Nowe zadanie", systemImage: "plus")
            }
            .keyboardShortcut("n", modifiers: .command)
            .help("Nowe zadanie (⌘N)")
        }
    }

    // MARK: - Bannery
    @ViewBuilder
    private var bannersSection: some View {
        if vm.showDailyPenaltyBanner {
            PenaltyBannerView(hpLost: vm.dailyPenaltyAmount)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        }
        if vm.showWeeklyResetBanner {
            WeeklyResetBannerView()
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        }
        if vm.showLevelUpBanner {
            LevelUpBannerView(level: vm.levelUpValue)
                .padding(.top, 8)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        }
        if vm.showAchievementBanner, let ach = vm.newlyUnlockedAchievement {
            AchievementBannerView(achievement: ach)
                .padding(.top, 8)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        }
        if vm.showChallengeCompletedBanner {
            ChallengeCompletedBannerView()
                .padding(.top, 8)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        }
        if vm.showWheel, let reward = vm.wheelReward {
            MacWheelRewardBannerView(reward: reward)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - Quick Start
    @ViewBuilder
    private var quickStartSection: some View {
        if let task = vm.randomTask {
            QuickStartCardView(
                taskTitle: task.title,
                onDone: { vm.toggle(task: task) }
            )
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    // MARK: - Wheel & Chaos Row
    @ViewBuilder
    private var wheelAndChaosRow: some View {
        let boosts = vm.profile.activeBoosts.filter { Date() < $0.value }
        if !boosts.isEmpty || vm.chaosModeActive {
            HStack(spacing: 8) {
                ForEach(Array(boosts.keys), id: \.self) { key in
                    BoostBadgeView(key: key, expiry: boosts[key]!)
                }
                Spacer()
                if vm.chaosModeActive {
                    Button { vm.toggleChaosMode() } label: {
                        HStack(spacing: 4) {
                            Text("🔥").font(.caption)
                            Text("Chaos Mode").font(.caption).bold()
                            Image(systemName: "xmark.circle.fill").font(.caption2)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().fill(Color.red.opacity(0.12)))
                        .foregroundColor(.red)
                        .overlay(Capsule().strokeBorder(Color.red.opacity(0.25), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    // MARK: - Filtry kategorii
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                MacCategoryChip(
                    label: "Wszystkie",
                    icon: "square.grid.2x2.fill",
                    color: Color.gray,
                    isSelected: selectedCategory == nil
                ) { selectedCategory = nil }

                ForEach(TaskCategory.allCases, id: \.self) { cat in
                    MacCategoryChip(
                        label: cat.rawValue,
                        icon: cat.icon,
                        color: cat.swiftUIColor,
                        isSelected: selectedCategory == cat
                    ) {
                        selectedCategory = (cat == selectedCategory) ? nil : cat
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Lista zadań
    private var taskListSection: some View {
        ScrollView {
            LazyVStack(spacing: 12, pinnedViews: .sectionHeaders) {
                if filteredTasks.isEmpty {
                    emptyState
                } else if selectedFrequency == nil {
                    ForEach(TaskFrequency.allCases, id: \.self) { freq in
                        let tasks = filteredTasks.filter { $0.frequency == freq }
                        if !tasks.isEmpty {
                            Section {
                                ForEach(tasks) { task in
                                    MacTaskRow(task: task, vm: vm)
                                }
                            } header: {
                                MacSectionHeader(frequency: freq, tasks: tasks)
                            }
                        }
                    }
                } else {
                    ForEach(filteredTasks) { task in
                        MacTaskRow(task: task, vm: vm)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(Color.green)
            Text("Wszystkie zadania ukończone! 🎉")
                .font(.title3).bold()
            Text("Wybierz inną kategorię lub dodaj nowe zadanie")
                .font(.subheadline).foregroundStyle(.secondary)
            Button { showAddTask = true } label: {
                Label("Dodaj zadanie", systemImage: "plus.circle.fill")
                    .font(.subheadline).bold()
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Capsule().fill(Color.blue))
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(60)
    }
}

// MARK: - Mac Wheel Reward Banner
private struct MacWheelRewardBannerView: View {
    let reward: WheelReward

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reward.icon)
                .font(.title2).foregroundColor(.purple)
            VStack(alignment: .leading, spacing: 2) {
                Text("🎉 Nagroda z koła!").font(.subheadline).bold()
                Text(reward.rawValue).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.purple.opacity(0.1)))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.purple.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Mac Task Row
private struct MacTaskRow: View {
    let task: CleaningTask
    @ObservedObject var vm: AppViewModel

    var body: some View {
        HStack(spacing: 14) {
            Button { vm.toggle(task: task) } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(
                            task.isDone ? Color.clear : Color.gray.opacity(0.3),
                            lineWidth: 1.5
                        )
                        .frame(width: 22, height: 22)
                    if task.isDone {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            Image(systemName: task.category.icon)
                .font(.subheadline)
                .foregroundColor(task.category.swiftUIColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isDone, color: Color.secondary)
                    .foregroundColor(task.isDone ? .secondary : .primary)
                HStack(spacing: 8) {
                    Text(task.difficulty.icon + " \(task.difficulty.rawValue)")
                        .font(.caption2).foregroundStyle(.secondary)
                    Text("+\(task.exp) XP")
                        .font(.caption2).foregroundStyle(.secondary)
                    Text("· \(task.gold)g")
                        .font(.caption2).foregroundStyle(.secondary)
                    if task.isCustom {
                        Text("własne")
                            .font(.caption2).bold()
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(Capsule().fill(Color.blue.opacity(0.1)))
                            .foregroundColor(.blue)
                    }
                }
            }

            Spacer()

            Text(task.category.rawValue)
                .font(.caption2).bold()
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(task.category.swiftUIColor.opacity(0.12)))
                .foregroundColor(task.category.swiftUIColor)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(task.isDone ? 0.02 : 0.05),
                    radius: 3, x: 0, y: 1
                )
        )
        .opacity(task.isDone ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: task.isDone)
    }
}

// MARK: - Mac Section Header
private struct MacSectionHeader: View {
    let frequency: TaskFrequency
    let tasks: [CleaningTask]

    private var done: Int        { tasks.filter { $0.isDone }.count }
    private var total: Int       { tasks.count }
    private var progress: Double { total > 0 ? Double(done) / Double(total) : 0 }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: frequency.icon)
                .font(.caption).bold()
                .foregroundColor(frequency.swiftUIColor)
            Text(frequency.rawValue)
                .font(.subheadline).bold()
                .foregroundColor(frequency.swiftUIColor)
            Spacer()
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemFill))
                        .frame(height: 5)
                    Capsule()
                        .fill(progress >= 1 ? Color.green : frequency.swiftUIColor)
                        .frame(width: geo.size.width * progress, height: 5)
                        .animation(.spring(response: 0.4), value: progress)
                }
            }
            .frame(width: 80, height: 5)

            Text("\(done)/\(total)")
                .font(.caption).bold()
                .foregroundColor(.secondary)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Capsule().fill(Color(.systemFill)))
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Mac Category Chip
private struct MacCategoryChip: View {
    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption)
                Text(label).font(.caption).bold()
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Capsule().fill(isSelected ? color : color.opacity(0.12)))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
