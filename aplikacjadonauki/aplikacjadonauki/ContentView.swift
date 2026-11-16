import SwiftUI

struct ContentView: View {
    @StateObject private var vm       = AppViewModel()
    @ObservedObject private var settings = SettingsStore.shared
    @State private var selectedTab    = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab(vm: vm, settings: settings)
                .tabItem { Label("Główna", systemImage: "house.fill") }
                .tag(0)

            TasksTabView(vm: vm)
                .tabItem { Label("Zadania", systemImage: "checklist") }
                .tag(1)

            StatsTabView(vm: vm)
                .tabItem { Label("Statystyki", systemImage: "chart.bar.fill") }
                .tag(2)

            ShopView(vm: vm)
                .tabItem { Label("Sklep", systemImage: "bag.fill") }
                .tag(3)

            ProfileTabView(vm: vm)
                .tabItem { Label("Profil", systemImage: "person.fill") }
                .tag(4)
        }
        .tint(settings.colorFor(settings.accentColorName))
    }
}

// MARK: - HomeTab
private struct HomeTab: View {
    @ObservedObject var vm: AppViewModel
    @ObservedObject var settings: SettingsStore

    @State private var showShop       = false
    @State private var showStatsSheet = false
    @State private var focusTaskID: UUID?

    private var accent: Color {
        settings.colorFor(settings.accentColorName)
    }

    /// XP zdobyte na bieżącym poziomie (z paska postępu).
    private var xpInLevel: Int {
        Int((vm.levelProgress * Double(vm.xpForNextLevel)).rounded())
    }

    private var dailyTasks: [CleaningTask] {
        vm.tasks.filter { $0.frequency == .daily }
    }

    /// Stabilne zadanie "Następny krok" (nie zmienia się przy każdym odświeżeniu widoku).
    private var focusTask: CleaningTask? {
        if let id = focusTaskID,
           let task = vm.tasks.first(where: { $0.id == id && !$0.isDone }) {
            return task
        }
        return vm.pendingTasks.first
    }

    private var hpColor: Color {
        vm.playerHP > 50 ? .green : (vm.playerHP > 25 ? .orange : .red)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let base: String
        switch hour {
        case 5..<12:  base = "Dzień dobry"
        case 12..<18: base = "Cześć"
        default:      base = "Dobry wieczór"
        }
        let name = vm.profile.name.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? base : "\(base), \(name)"
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground).ignoresSafeArea()
                LinearGradient(
                    colors: [accent.opacity(0.16), Color.clear],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        header
                        DailyProgressRing(
                            done: dailyTasks.filter { $0.isDone }.count,
                            total: dailyTasks.count,
                            accent: accent
                        )
                        focusCard
                        if vm.profile.pointsToAllocate > 0 { allocateCard }
                        levelCard
                        statsRow
                        actionsRow
                        activeBoostsSection
                    }
                    .frame(maxWidth: 640)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                    .frame(maxWidth: .infinity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showStatsSheet) {
                StatsTabView(vm: vm)
            }
            .sheet(isPresented: $showShop) {
                ShopView(vm: vm)
            }
        }
    }

    // MARK: - Nagłówek
    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.title2.bold())
                Text(vm.profile.displayTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Label("\(vm.streak) tyg.", systemImage: "flame.fill")
                .font(.subheadline.bold())
                .foregroundStyle(.orange)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(Color.orange.opacity(0.15)))
                .accessibilityLabel("Seria: \(vm.streak) tygodni")
        }
        .padding(.top, 4)
    }

    // MARK: - Następny krok
    @ViewBuilder
    private var focusCard: some View {
        if let task = focusTask {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Następny krok", systemImage: "scope")
                        .font(.subheadline.bold())
                        .foregroundStyle(accent)
                    Spacer()
                    Button {
                        Haptics.tap()
                        focusTaskID = vm.pendingTasks.filter { $0.id != task.id }.randomElement()?.id
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .frame(width: 36, height: 36)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Wylosuj inne zadanie")
                }

                Text(task.title)
                    .font(.title3.bold())
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    chip("\(task.exp) XP", icon: "bolt.fill", color: .blue)
                    chip("\(task.gold) Gold", icon: "dollarsign.circle.fill", color: .yellow)
                    chip(task.category.rawValue, icon: task.category.icon, color: task.category.swiftUIColor)
                }

                Button {
                    HapticManager.notification(true)
                    SoundManager.shared.playTick()
                    vm.toggle(task: task)
                    focusTaskID = nil
                } label: {
                    Label("Zrobione", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous).fill(accent)
                        )
                }
                .buttonStyle(.plain)
            }
            .appCard(tint: accent)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                Text("Wszystko zrobione!")
                    .font(.headline)
                Text("Odpocznij albo dodaj nowe zadanie w zakładce Zadania.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .appCard()
        }
    }

    private func chip(_ text: String, icon: String, color: Color) -> some View {
        Label(text, systemImage: icon)
            .font(.caption.bold())
            .foregroundStyle(color)
            .lineLimit(1)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Capsule().fill(color.opacity(0.14)))
    }

    // MARK: - Punkty do rozdania
    private var allocateCard: some View {
        Button { showStatsSheet = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Masz \(vm.profile.pointsToAllocate) punkt(y) do rozdania")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    Text("Dotknij, aby rozdzielić statystyki")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .appCard(tint: .yellow)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Poziom, HP, złoto
    private var levelCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [accent, accent.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 56, height: 56)
                    VStack(spacing: 0) {
                        Text("LVL")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white.opacity(0.9))
                        Text("\(vm.level)")
                            .font(.title2.weight(.black))
                            .foregroundColor(.white)
                    }
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(vm.isMasterLevel ? "Poziom MAX" : "Poziom \(vm.level)")
                        .font(.headline)
                    progressBar(value: vm.levelProgress, colors: [accent, accent.opacity(0.7)], height: 10)
                    HStack {
                        Text(vm.isMasterLevel ? "Mistrz Czystości" : "\(xpInLevel) / \(vm.xpForNextLevel) XP")
                        Spacer()
                        Text("Razem \(vm.experience) XP")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            Divider()

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("HP \(vm.playerHP)/100", systemImage: "heart.fill")
                        .font(.caption.bold())
                        .foregroundStyle(hpColor)
                    progressBar(value: Double(vm.playerHP) / 100.0, colors: [hpColor, hpColor.opacity(0.7)], height: 8)
                }
                Label("\(vm.gold)", systemImage: "dollarsign.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Capsule().fill(Color.yellow.opacity(0.14)))
                    .accessibilityLabel("Złoto: \(vm.gold)")
            }
        }
        .appCard()
    }

    private func progressBar(value: Double, colors: [Color], height: CGFloat) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(.systemFill))
                Capsule()
                    .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * CGFloat(min(max(value, 0), 1)))
                    .animation(.spring(response: 0.6), value: value)
            }
        }
        .frame(height: height)
    }

    // MARK: - Statystyki postaci
    private var statsRow: some View {
        let items: [(String, String, Int, Color)] = [
            ("figure.strengthtraining.traditional", "Siła", vm.profile.stats[.strength] ?? 1, .red),
            ("brain.head.profile", "Intel", vm.profile.stats[.intelligence] ?? 1, .blue),
            ("scope", "Zręczność", vm.profile.stats[.dexterity] ?? 1, .green),
            ("flame.fill", "Wola", vm.profile.stats[.willpower] ?? 1, .orange)
        ]
        return HStack(spacing: 10) {
            ForEach(items, id: \.1) { item in
                VStack(spacing: 6) {
                    Image(systemName: item.0)
                        .font(.title3)
                        .foregroundStyle(item.3)
                    Text("\(item.2)")
                        .font(.title3.bold())
                    Text(item.1)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(item.3.opacity(0.10))
                )
                .accessibilityElement(children: .combine)
            }
        }
    }

    // MARK: - Szybkie akcje
    private var actionsRow: some View {
        HStack(spacing: 12) {
            actionButton(
                icon: vm.hasSpunWheelToday ? "checkmark.circle.fill" : "sparkles",
                title: "Koło",
                subtitle: vm.hasSpunWheelToday ? "Wróć jutro" : "Nagroda!",
                color: .purple
            ) {
                HapticManager.impact(.rigid)
                SoundManager.shared.playMagic()
                vm.spinWheel()
            }
            .disabled(vm.hasSpunWheelToday)

            actionButton(
                icon: vm.chaosModeActive ? "flame.fill" : "bolt.fill",
                title: vm.chaosModeActive ? "Chaos: wł." : "Chaos",
                subtitle: vm.chaosModeActive ? "Wyłącz" : "Szybkie zadania",
                color: vm.chaosModeActive ? .red : .orange
            ) {
                HapticManager.impact(vm.chaosModeActive ? .soft : .heavy)
                SoundManager.shared.playWhoosh()
                vm.toggleChaosMode()
            }

            actionButton(
                icon: "bag.fill",
                title: "Sklep",
                subtitle: "\(vm.gold) złota",
                color: .yellow
            ) {
                HapticManager.impact(.light)
                showShop = true
            }
        }
    }

    private func actionButton(icon: String, title: String, subtitle: String,
                              color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(color.opacity(0.15)))
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Aktywne boosty
    @ViewBuilder
    private var activeBoostsSection: some View {
        let boosts = vm.profile.activeBoosts.filter { Date() < $0.value }
        if !boosts.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Aktywne boosty")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(boosts.keys), id: \.self) { key in
                            BoostBadgeView(key: key, expiry: boosts[key]!)
                        }
                    }
                }
            }
        }
    }
}
