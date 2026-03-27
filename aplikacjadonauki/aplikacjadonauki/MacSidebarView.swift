import SwiftUI

struct MacSidebarView: View {
    @ObservedObject var vm: AppViewModel
    @Binding var selectedFrequency: TaskFrequency?
    @Binding var showStats: Bool
    @State private var showAchievements = false
    @State private var showShop         = false
    @State private var showProfile      = false

    var body: some View {
        List(selection: $selectedFrequency) {
            profileSection
            xpSection
            challengeSection
            navigationSection
            toolsSection
        }
        .listStyle(.sidebar)
        .navigationTitle("Czystość")
        .sheet(isPresented: $showStats)        { WeeklyStatsView(vm: vm) }
        .sheet(isPresented: $showAchievements) { AchievementsView(vm: vm) }
        .sheet(isPresented: $showShop)         { ShopView(vm: vm) }
        .sheet(isPresented: $showProfile)      { ProfileView(vm: vm) }
    }

    // MARK: - Profil
    private var profileSection: some View {
        Group {
            Button { showProfile = true } label: {
                HStack(spacing: 12) {
                    Text(vm.profile.avatarEmoji)
                        .font(.system(size: 36))
                        .padding(10)
                        .background(
                            Circle().fill(
                                LinearGradient(
                                    colors: vm.isMasterLevel
                                        ? [.yellow.opacity(0.2), .orange.opacity(0.1)]
                                        : [.green.opacity(0.15), .teal.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(vm.profile.name)
                            .font(.headline).bold()
                            .foregroundColor(.primary)
                        Text(vm.profile.displayTitle)       // ✅ displayTitle zamiast title
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
            .listRowSeparator(.hidden)

            Divider()
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
        }
    }

    // MARK: - XP + Złoto + Seria
    private var xpSection: some View {
        Group {
            VStack(spacing: 8) {
                xpHeader
                xpProgressBar
                goldAndStreak
                hpBar                                       // ✅ nowe – HP widoczne w sidebarze
            }
            .padding(.vertical, 4)
            .listRowSeparator(.hidden)

            Divider()
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
        }
    }

    private var xpHeader: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: vm.isMasterLevel ? "trophy.fill" : "star.fill")
                    .font(.caption)
                    .foregroundColor(vm.isMasterLevel ? .yellow : .purple)
                Text(vm.isMasterLevel ? "Mistrz Czystości" : "Poziom \(vm.level)")
                    .font(.subheadline).bold()
            }
            Spacer()
            HStack(spacing: 3) {
                Image(systemName: "bolt.fill")
                    .font(.caption2)
                    .foregroundColor(.blue)
                Text("\(vm.experience) XP")
                    .font(.caption2).bold()
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var xpProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemFill))
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 6)
                    .fill(LinearGradient(
                        colors: vm.isMasterLevel ? [.yellow, .orange] : [.green, .teal],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(
                        width: geo.size.width * (vm.isMasterLevel ? 1.0 : vm.levelProgress),
                        height: 8
                    )
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: vm.levelProgress)
            }
        }
        .frame(height: 8)
    }

    private var goldAndStreak: some View {
        HStack {
            HStack(spacing: 3) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
                Text("\(vm.gold) 🪙")
                    .font(.caption2).bold()
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 3) {
                Image(systemName: "flame.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
                Text("Seria: \(vm.streak)")
                    .font(.caption2).bold()
                    .foregroundStyle(.secondary)
            }
        }
    }

    // ✅ nowe – pasek HP w sidebarze
    private var hpBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "heart.fill")
                .font(.caption2)
                .foregroundColor(vm.playerHP < 30 ? .red : .green)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemFill))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(vm.playerHP < 30 ? Color.red : Color.green)
                        .frame(
                            width: geo.size.width * (Double(vm.playerHP) / 100.0),
                            height: 6
                        )
                        .animation(.spring(response: 0.4), value: vm.playerHP)
                }
            }
            .frame(height: 6)
            Text("\(vm.playerHP)/100")
                .font(.caption2).bold()
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }

    // MARK: - Wyzwanie tygodnia
    @ViewBuilder
    private var challengeSection: some View {
        if let challenge = vm.weeklyChallenge {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption2)
                        .foregroundColor(.teal)
                    Text("Wyzwanie tygodnia")
                        .font(.caption).bold()
                        .foregroundColor(.teal)
                    Spacer()
                    if challenge.isCompleted {
                        Text("✅").font(.caption)
                    }
                }
                Text(challenge.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                GeometryReader { geo in
                    let progress = min(
                        1.0,
                        Double(challenge.currentCount) / Double(challenge.targetCount)
                    )
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemFill))
                            .frame(height: 5)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(challenge.isCompleted ? Color.green : Color.teal)
                            .frame(width: geo.size.width * progress, height: 5)
                            .animation(.spring(response: 0.4), value: challenge.currentCount)
                    }
                }
                .frame(height: 5)

                HStack {
                    Text("\(challenge.currentCount)/\(challenge.targetCount) zadań")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text("+\(challenge.bonusGold)g bonus")  // ✅ bonus gold info
                        .font(.caption2).bold()
                        .foregroundColor(.yellow)
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.teal.opacity(0.07)))
            .listRowSeparator(.hidden)

            Divider()
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
        }
    }

    // MARK: - Nawigacja zadań
    private var navigationSection: some View {
        Section("Zadania") {
            // Wszystkie zadania
            NavigationLink(value: TaskFrequency?.none) {
                Label {
                    HStack {
                        Text("Wszystkie")
                        Spacer()
                        let count = vm.tasks.filter { !$0.isDone }.count
                        if count > 0 {
                            badgeView(count: count, color: .gray)
                        }
                    }
                } icon: {
                    Image(systemName: "square.grid.2x2.fill")
                        .foregroundColor(.gray)
                }
            }
            .tag(TaskFrequency?.none)

            // Per-częstotliwość
            ForEach(TaskFrequency.allCases, id: \.self) { freq in
                NavigationLink(value: Optional(freq)) {
                    Label {
                        HStack {
                            Text(freq.rawValue)
                            Spacer()
                            let count = vm.tasks.filter { $0.frequency == freq && !$0.isDone }.count
                            if count > 0 {
                                badgeView(count: count, color: freq.swiftUIColor)
                            }
                        }
                    } icon: {
                        Image(systemName: freq.icon)
                            .foregroundColor(freq.swiftUIColor)
                    }
                }
                .tag(Optional(freq))
            }
        }
    }

    // MARK: - Narzędzia
    private var toolsSection: some View {
        Section("Narzędzia") {
            // Statystyki
            Button { showStats = true } label: {
                Label("Statystyki tygodnia", systemImage: "chart.bar.fill")
                    .foregroundColor(.purple)
            }
            .buttonStyle(.plain)
            .listRowSeparator(.hidden)

            // Osiągnięcia
            Button { showAchievements = true } label: {
                HStack {
                    Label("Osiągnięcia", systemImage: "trophy.fill")
                        .foregroundColor(.yellow)
                    Spacer()
                    Text("\(vm.unlockedAchievements.count)/\(vm.achievements.count)")
                        .font(.caption2).bold()
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .listRowSeparator(.hidden)

            // Sklep
            Button { showShop = true } label: {
                HStack {
                    Label("Sklep", systemImage: "bag.fill")
                        .foregroundColor(.orange)
                    Spacer()
                    Text("\(vm.gold) 🪙")
                        .font(.caption2).bold()
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .listRowSeparator(.hidden)

            // ✅ nowe – HP Potion shortcut jeśli HP niskie
            if vm.playerHP < 30 {
                Button {
                    if let potion = vm.shopItems.first(where: { $0.title.contains("Potion") }) {
                        vm.buyItem(potion)
                    }
                } label: {
                    HStack {
                        Label("Kup HP Potion!", systemImage: "heart.fill")
                            .foregroundColor(.red)
                        Spacer()
                        Text("30g")
                            .font(.caption2).bold()
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .disabled(vm.gold < 30)
            }

            // ✅ nowe – Daily Wheel shortcut
            Button { vm.spinWheel() } label: {
                HStack {
                    Label(
                        vm.hasSpunWheelToday ? "Koło obrócone ✓" : "Dzienne Koło 🎡",
                        systemImage: "circle.grid.cross.fill"
                    )
                    .foregroundColor(vm.hasSpunWheelToday ? .secondary : .purple)
                    Spacer()
                    if vm.hasSpunWheelToday {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }
            .buttonStyle(.plain)
            .listRowSeparator(.hidden)
            .disabled(vm.hasSpunWheelToday)
        }
    }

    // MARK: - Badge Helper
    private func badgeView(count: Int, color: Color) -> some View {
        Text("\(count)")
            .font(.caption2).bold()
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(color))
    }
}
