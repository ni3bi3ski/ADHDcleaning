import SwiftUI

struct TasksTabView: View {
    @ObservedObject var vm: AppViewModel
    @State private var showAddTask     = false
    @State private var selectedFilter: TaskFrequency? = nil

    var filteredTasks: [CleaningTask] {
        selectedFilter == nil
            ? vm.tasks
            : vm.tasks.filter { $0.frequency == selectedFilter }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    bannersSection
                    progressSection
                    wheelSection
                    chaosModeSection
                    filterSection
                    taskListSection
                }
                .frame(maxWidth: 640)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Zadania")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .accessibilityLabel("Dodaj zadanie")
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(vm: vm)
            }
            .onAppear {
                vm.checkDailyReset()
            }
            .overlay {
                if vm.showLevelUpBanner {
                    ConfettiView()
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
            .onChange(of: vm.showLevelUpBanner) { _, isShown in
                if isShown { Haptics.success() }
            }
        }
    }

    // MARK: - Dzisiejszy postęp
    private var progressSection: some View {
        let daily = vm.tasks.filter { $0.frequency == .daily }
        return DailyProgressRing(
            done: daily.filter { $0.isDone }.count,
            total: daily.count,
            accent: .accentColor
        )
        .padding(.horizontal)
    }

    // MARK: - Bannery
    @ViewBuilder
    private var bannersSection: some View {
        if vm.showDailyPenaltyBanner {
            PenaltyBannerView(hpLost: vm.dailyPenaltyAmount)
                .padding(.horizontal, 16).padding(.top, 8)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: vm.showDailyPenaltyBanner)
        }
        if vm.showWeeklyResetBanner {
            WeeklyResetBannerView()
                .padding(.horizontal, 16).padding(.top, 8)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: vm.showWeeklyResetBanner)
        }
        if vm.showLevelUpBanner {
            LevelUpBannerView(level: vm.levelUpValue)
                .padding(.top, 8)
                .transition(AnyTransition.scale.combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.showLevelUpBanner)
        }
        if vm.showAchievementBanner, let ach = vm.newlyUnlockedAchievement {
            AchievementBannerView(achievement: ach)
                .padding(.top, 8)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: vm.showAchievementBanner)
        }
        if vm.showChallengeCompletedBanner {
            ChallengeCompletedBannerView()
                .padding(.top, 8)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: vm.showChallengeCompletedBanner)
        }
    }

    // MARK: - Karta akcji (Koło, Chaos)
    private func actionRow(icon: String, color: Color, title: String,
                           subtitle: String, showChevron: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(Circle().fill(color.opacity(0.15)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .appCard(tint: color == .gray ? nil : color)
    }

    // MARK: - Daily Wheel
    private var wheelSection: some View {
        VStack(spacing: 8) {
            Button {
                Haptics.tap()
                vm.spinWheel()
            } label: {
                actionRow(
                    icon: vm.hasSpunWheelToday ? "checkmark.circle.fill" : "sparkles",
                    color: vm.hasSpunWheelToday ? .gray : .purple,
                    title: vm.hasSpunWheelToday ? "Koło obrócone dziś" : "Obróć Dzienne Koło",
                    subtitle: vm.hasSpunWheelToday ? "Wróć jutro po nagrodę" : "Losowa nagroda co 24 h",
                    showChevron: !vm.hasSpunWheelToday
                )
            }
            .buttonStyle(.plain)
            .disabled(vm.hasSpunWheelToday)
            .padding(.horizontal)

            if vm.showWheel, let reward = vm.wheelReward {
                WheelRewardBannerView(reward: reward)
                    .padding(.horizontal, 16).padding(.top, 8)
                    .transition(AnyTransition.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.showWheel)
            }

            activeBoostsRow
        }
    }

    // MARK: - Aktywne Boosty
    @ViewBuilder
    private var activeBoostsRow: some View {
        let boosts = vm.profile.activeBoosts.filter { Date() < $0.value }
        if !boosts.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(boosts.keys), id: \.self) { key in
                        BoostBadgeView(key: key, expiry: boosts[key]!)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Chaos Mode
    private var chaosModeSection: some View {
        Button {
            Haptics.tap()
            vm.toggleChaosMode()
        } label: {
            actionRow(
                icon: vm.chaosModeActive ? "flame.fill" : "bolt.fill",
                color: vm.chaosModeActive ? .red : .orange,
                title: vm.chaosModeActive ? "Chaos Mode aktywny" : "Chaos Mode",
                subtitle: vm.chaosModeActive
                    ? "Dodano 4 mini-zadania. Dotknij, aby wyłączyć"
                    : "Brak sił? Dodaj 4 bardzo małe zadania",
                showChevron: false
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    // MARK: - Filtry
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "Wszystkie", icon: "list.bullet", color: .gray,
                           isSelected: selectedFilter == nil) { selectedFilter = nil }
                FilterChip(label: "Dzienne", icon: "sun.max.fill", color: .orange,
                           isSelected: selectedFilter == .daily) { selectedFilter = .daily }
                FilterChip(label: "Tygodniowe", icon: "calendar.badge.clock", color: .blue,
                           isSelected: selectedFilter == .weekly) { selectedFilter = .weekly }
                FilterChip(label: "Miesięczne", icon: "calendar", color: .purple,
                           isSelected: selectedFilter == .monthly) { selectedFilter = .monthly }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }

    // MARK: - Lista zadań
    private var taskListSection: some View {
        LazyVStack(spacing: 10) {
            if filteredTasks.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.green)
                    Text("Wszystko zrobione!")
                        .font(.title3).bold()
                    Text("Brak zadań w tej kategorii")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Button {
                        showAddTask = true
                    } label: {
                        Label("Dodaj zadanie", systemImage: "plus.circle.fill")
                            .font(.subheadline).bold()
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(Capsule().fill(Color.accentColor))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                let dailyTasks   = filteredTasks.filter { $0.frequency == .daily }
                let weeklyTasks  = filteredTasks.filter { $0.frequency == .weekly }
                let monthlyTasks = filteredTasks.filter { $0.frequency == .monthly }

                if !dailyTasks.isEmpty {
                    sectionHeader(title: "Dzienne", icon: "sun.max.fill", color: .orange,
                                  done: dailyTasks.filter { $0.isDone }.count, total: dailyTasks.count)
                    ForEach(dailyTasks) { task in
                        TaskRowView(
                            title: task.title,
                            exp: task.exp,
                            isDone: task.isDone,
                            category: task.category,
                            difficulty: task.difficulty,
                            onToggle: { vm.toggle(task: task) }
                        )
                        .padding(.horizontal)
                    }
                }

                if !weeklyTasks.isEmpty {
                    sectionHeader(title: "Tygodniowe", icon: "calendar.badge.clock", color: .blue,
                                  done: weeklyTasks.filter { $0.isDone }.count, total: weeklyTasks.count)
                    ForEach(weeklyTasks) { task in
                        TaskRowView(
                            title: task.title,
                            exp: task.exp,
                            isDone: task.isDone,
                            category: task.category,
                            difficulty: task.difficulty,
                            onToggle: { vm.toggle(task: task) }
                        )
                        .padding(.horizontal)
                    }
                }

                if !monthlyTasks.isEmpty {
                    sectionHeader(title: "Miesięczne", icon: "calendar", color: .purple,
                                  done: monthlyTasks.filter { $0.isDone }.count, total: monthlyTasks.count)
                    ForEach(monthlyTasks) { task in
                        TaskRowView(
                            title: task.title,
                            exp: task.exp,
                            isDone: task.isDone,
                            category: task.category,
                            difficulty: task.difficulty,
                            onToggle: { vm.toggle(task: task) }
                        )
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.bottom, 24)
    }

    private func sectionHeader(title: String, icon: String, color: Color, done: Int, total: Int) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption.bold())
            Text(title)
                .font(.subheadline).bold()
                .foregroundColor(color)
            Spacer()
            Text("\(done)/\(total)")
                .font(.caption).bold()
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Capsule().fill(Color(.systemFill)))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Wheel Reward Banner
    struct WheelRewardBannerView: View {
        let reward: WheelReward
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: reward.icon)
                    .font(.title2).foregroundColor(.purple)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Nagroda z koła!").font(.subheadline).bold()
                    Text(reward.rawValue).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.purple.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.purple.opacity(0.25), lineWidth: 1))
        }
    }

    // MARK: - Add Task View
    struct AddTaskView: View {
        @ObservedObject var vm: AppViewModel
        @Environment(\.dismiss) private var dismiss

        @State private var title      = ""
        @State private var category   = TaskCategory.general
        @State private var difficulty = TaskDifficulty.easy
        @State private var frequency  = TaskFrequency.daily

        var body: some View {
            NavigationStack {
                Form {
                    Section("Nazwa zadania") {
                        TextField("np. Wytrzyj blaty", text: $title)
                    }

                    Section("Kategoria") {
                        Picker("Kategoria", selection: $category) {
                            ForEach(TaskCategory.allCases, id: \.self) { cat in
                                Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                            }
                        }
                    }

                    Section("Trudność") {
                        Picker("Trudność", selection: $difficulty) {
                            ForEach(TaskDifficulty.allCases, id: \.self) { diff in
                                Text("\(diff.icon) \(diff.rawValue)").tag(diff)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("Częstotliwość") {
                        Picker("Częstotliwość", selection: $frequency) {
                            ForEach(TaskFrequency.allCases, id: \.self) { freq in
                                Text(freq.rawValue).tag(freq)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section {
                        let xp  = CleaningTask(title: title, category: category,
                                               difficulty: difficulty, frequency: frequency).exp
                        let gld = xp / 3
                        HStack {
                            Label("\(xp) XP", systemImage: "bolt.fill").foregroundColor(.blue)
                            Spacer()
                            Label("\(gld) Gold", systemImage: "dollarsign.circle.fill").foregroundColor(.yellow)
                        }
                    } header: {
                        Text("Nagroda za wykonanie")
                    }
                }
                .navigationTitle("Nowe zadanie")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Anuluj") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Dodaj") {
                            guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            vm.addCustomTask(title: title, category: category,
                                             difficulty: difficulty, frequency: frequency)
                            dismiss()
                        }
                        .bold()
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }
}
