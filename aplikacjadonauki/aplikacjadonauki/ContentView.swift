import SwiftUI

struct ContentView: View {
    @StateObject private var vm       = AppViewModel()
    @StateObject private var settings = SettingsStore()
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

    private var accentColor: Color {
        settings.colorFor(settings.accentColorName)
    }

    /// XP zdobyte na bieżącym poziomie (z paska postępu).
    private var xpInLevel: Int {
        Int((vm.levelProgress * Double(vm.xpForNextLevel)).rounded())
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [
                        accentColor.opacity(0.18),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        heroCard
                        if vm.profile.pointsToAllocate > 0 { allocateCard }
                        statsRow
                        quickTaskCard
                        actionsRow
                        activeBoostsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showStatsSheet) {
                StatsTabView(vm: vm)
            }
            .sheet(isPresented: $showShop) {
                ShopView(vm: vm)
            }
        }
    }

    // MARK: - Hero Card
    private var heroCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [accentColor.opacity(0.22), accentColor.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: accentColor.opacity(0.18), radius: 20, x: 0, y: 8)

            VStack(spacing: 16) {
                HStack(alignment: .center, spacing: 14) {
                    // Badge poziomu
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [accentColor, accentColor.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 58, height: 58)
                            .shadow(color: accentColor.opacity(0.5), radius: 10, x: 0, y: 4)
                        VStack(spacing: 0) {
                            Text("LVL")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white.opacity(0.85))
                            Text("\(vm.level)")
                                .font(.system(size: 22, weight: .black))
                                .foregroundColor(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(vm.profile.name)
                                    .font(.title3).bold()
                                Text(vm.profile.displayTitle)
                                    .font(.caption2).foregroundStyle(.secondary)
                            }
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                    .font(.subheadline)
                                Text("\(vm.streak)t")
                                    .font(.subheadline).bold()
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Capsule().fill(Color.orange.opacity(0.12)))
                        }

                        // XP Bar
                        VStack(alignment: .leading, spacing: 4) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(.systemFill))
                                        .frame(height: 8)
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [accentColor, accentColor.opacity(0.7)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * vm.levelProgress, height: 8)
                                        .animation(.spring(response: 0.6), value: vm.levelProgress)
                                }
                            }
                            .frame(height: 8)
                            .accessibilityElement()
                            .accessibilityLabel("Postęp poziomu")
                            .accessibilityValue("\(Int(vm.levelProgress * 100)) procent")

                            HStack {
                                Text(vm.isMasterLevel ? "Poziom MAX" : "\(xpInLevel) / \(vm.xpForNextLevel) XP")
                                    .font(.caption2).foregroundStyle(.secondary)
                                Spacer()
                                Text("Razem \(vm.experience) XP")
                                    .font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Divider().opacity(0.3)

                // HP + Gold + Zadania dziś
                HStack(spacing: 0) {
                    // HP
                    VStack(spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill").foregroundColor(.red).font(.caption)
                            Text("HP").font(.caption2).bold().foregroundStyle(.secondary)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color(.systemFill)).frame(height: 6)
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: vm.playerHP > 50
                                                ? [.green, .mint]
                                                : vm.playerHP > 25
                                                    ? [.orange, .yellow]
                                                    : [.red, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * CGFloat(vm.playerHP) / 100.0, height: 6)
                                    .animation(.spring(response: 0.5), value: vm.playerHP)
                            }
                        }
                        .frame(height: 6)
                        Text("\(vm.playerHP)/100")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    Divider().frame(height: 40).opacity(0.3)

                    // Gold
                    VStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title3).foregroundColor(.yellow)
                        Text("\(vm.gold)")
                            .font(.title3).bold().foregroundColor(.yellow)
                        Text("Gold").font(.caption2).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    Divider().frame(height: 40).opacity(0.3)

                    // Zadania dziś
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3).foregroundColor(.green)
                        Text("\(vm.tasks.filter { $0.isDone && $0.frequency == .daily }.count)")
                            .font(.title3).bold().foregroundColor(.green)
                        Text("Dziś").font(.caption2).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
        }
        .padding(.top, 4)
    }

    // MARK: - Allocate Points Card
    private var allocateCard: some View {
        Button { showStatsSheet = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.yellow.opacity(0.15)).frame(width: 40, height: 40)
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.yellow).font(.title3)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Masz \(vm.profile.pointsToAllocate) punkt(y) do rozdania!")
                        .font(.subheadline).bold()
                    Text("Kliknij aby rozdzielić statystyki")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.yellow.opacity(0.10))
                    .overlay(RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.yellow.opacity(0.35), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        let stats: [(String, String, Color)] = [
            ("⚔️", "Siła \(vm.profile.stats[.strength] ?? 1)", .red),
            ("🧠", "Intel \(vm.profile.stats[.intelligence] ?? 1)", .blue),
            ("🎯", "Zręcz \(vm.profile.stats[.dexterity] ?? 1)", .green),
            ("🔥", "Wola \(vm.profile.stats[.willpower] ?? 1)", .orange)
        ]
        return HStack(spacing: 8) {
            ForEach(stats, id: \.1) { stat in
                VStack(spacing: 4) {
                    Text(stat.0).font(.title3)
                    Text(stat.1)
                        .font(.caption2.bold())
                        .foregroundColor(stat.2)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(stat.2.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(stat.2.opacity(0.2), lineWidth: 1))
                )
            }
        }
    }

    // MARK: - Quick Task Card
    private var quickTaskCard: some View {
        Group {
            if let task = vm.randomTask {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "bolt.fill").foregroundColor(accentColor)
                        Text("Szybkie zadanie")
                            .font(.caption).bold().foregroundStyle(.secondary)
                        Spacer()
                        Text("TERAZ")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(accentColor)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Capsule().fill(accentColor.opacity(0.15)))
                    }
                    Text(task.title).font(.headline)
                    HStack {
                        Label("\(task.exp) XP", systemImage: "bolt.fill")
                            .font(.caption).foregroundColor(.blue)
                        Label("\(task.exp / 3) Gold", systemImage: "dollarsign.circle.fill")
                            .font(.caption).foregroundColor(.yellow)
                        Spacer()
                        Button {
                            HapticManager.notification(true)
                            SoundManager.shared.playTick()
                            vm.toggle(task: task)
                        } label: {
                            Text("Zrobione ✓")
                                .font(.subheadline).bold()
                                .foregroundColor(.white)
                                .padding(.horizontal, 18).padding(.vertical, 8)
                                .background(Capsule().fill(accentColor))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.systemBackground))
                        .shadow(color: accentColor.opacity(0.10), radius: 10, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(accentColor.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Actions Row
    private var actionsRow: some View {
        HStack(spacing: 12) {
            // Koło nagród
            Button {
                HapticManager.impact(.rigid)
                SoundManager.shared.playMagic()
                vm.spinWheel()
            } label: {
                VStack(spacing: 8) {
                    Text(vm.hasSpunWheelToday ? "✅" : "🎡").font(.largeTitle)
                    Text(vm.hasSpunWheelToday ? "Obrócono" : "Koło").font(.caption).bold()
                    Text(vm.hasSpunWheelToday ? "Jutro" : "Nagroda!").font(.caption2).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(vm.hasSpunWheelToday ? Color.gray.opacity(0.07) : Color.purple.opacity(0.10))
                        .overlay(RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(vm.hasSpunWheelToday ? Color.gray.opacity(0.15) : Color.purple.opacity(0.3), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)
            .disabled(vm.hasSpunWheelToday)

            // Chaos Mode
            Button {
                HapticManager.impact(vm.chaosModeActive ? .soft : .heavy)
                SoundManager.shared.playWhoosh()
                vm.toggleChaosMode()
            } label: {
                VStack(spacing: 8) {
                    Text(vm.chaosModeActive ? "🔥" : "⚡").font(.largeTitle)
                    Text(vm.chaosModeActive ? "Aktywny!" : "Chaos")
                        .font(.caption).bold()
                        .foregroundColor(vm.chaosModeActive ? .red : .primary)
                    Text(vm.chaosModeActive ? "Wyłącz" : "ADHD mode").font(.caption2).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(vm.chaosModeActive ? Color.red.opacity(0.10) : Color.orange.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(vm.chaosModeActive ? Color.red.opacity(0.3) : Color.orange.opacity(0.2), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)

            // Sklep
            Button {
                HapticManager.impact(.light)
                showShop = true
            } label: {
                VStack(spacing: 8) {
                    Text("🛍️").font(.largeTitle)
                    Text("Sklep").font(.caption).bold()
                    Text("\(vm.gold) 🪙").font(.caption2).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.yellow.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Color.yellow.opacity(0.25), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Active Boosts
    @ViewBuilder
    private var activeBoostsSection: some View {
        let boosts = vm.profile.activeBoosts.filter { Date() < $0.value }
        if !boosts.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Aktywne boosty")
                    .font(.caption).bold().foregroundStyle(.secondary)
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
