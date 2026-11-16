import SwiftUI

struct ProfileTabView: View {
    @ObservedObject var vm: AppViewModel
    @ObservedObject private var settings = SettingsStore.shared
    @State private var showShop         = false
    @State private var showAchievements = false
    @State private var showEditProfile  = false
    @State private var showSettings     = false
    @State private var showResetAlert   = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    profileHeader
                    quickStatsRow
                    challengeSection
                    achievementsPreview
                    navigationCards
                    moodSection
                    dangerZone
                }
                .frame(maxWidth: 640)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel("Ustawienia")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                    }
                    .accessibilityLabel("Edytuj profil")
                }
            }
            .sheet(isPresented: $showShop)         { ShopView(vm: vm) }
            .sheet(isPresented: $showAchievements) { AchievementsView(vm: vm) }
            .sheet(isPresented: $showEditProfile)  { EditProfileView(vm: vm) }
            .sheet(isPresented: $showSettings)     { SettingsView(settings: settings, vm: vm) }
            .alert("Reset wszystkiego?", isPresented: $showResetAlert) {
                Button("Resetuj", role: .destructive) { vm.resetAll() }
                Button("Anuluj", role: .cancel) {}
            } message: {
                Text("Stracisz cały postęp, XP, gold i osiągnięcia. Nie można cofnąć!")
            }
        }
    }

    // MARK: - Nagłówek profilu
    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.accentColor.opacity(0.35), Color.purple.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 92, height: 92)
                Text(vm.profile.avatarEmoji)
                    .font(.system(size: 50))
            }
            .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text(vm.profile.name)
                    .font(.title2.bold())
                Text(vm.profile.displayTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            StatusChip(
                text: "\(vm.profile.playerClass.icon) \(vm.profile.playerClass.rawValue)",
                color: Color.accentColor
            )
        }
        .frame(maxWidth: .infinity)
        .appCard()
    }

    // MARK: - Szybkie statystyki
    private var quickStatsRow: some View {
        let items: [(String, String, String, Color)] = [
            ("checkmark.circle.fill", "Zadań", "\(vm.profile.totalTasksCompleted)", .green),
            ("flame.fill", "Seria (tyg.)", "\(vm.streak)", .orange),
            ("dollarsign.circle.fill", "Złoto", "\(vm.gold)", .yellow),
            ("star.fill", "Poziom", "\(vm.level)", .purple)
        ]
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
            ForEach(items, id: \.1) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.0)
                        .font(.title3)
                        .foregroundStyle(item.3)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(item.3.opacity(0.14)))
                    VStack(alignment: .leading, spacing: 0) {
                        Text(item.2)
                            .font(.title3.bold().monospacedDigit())
                        Text(item.1)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                .accessibilityElement(children: .combine)
            }
        }
    }

    // MARK: - Wyzwanie
    @ViewBuilder
    private var challengeSection: some View {
        if let challenge = vm.weeklyChallenge {
            WeeklyChallengeCardView(challenge: challenge)
        }
    }

    // MARK: - Osiągnięcia
    private var achievementsPreview: some View {
        Button { showAchievements = true } label: {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "trophy.fill").foregroundStyle(.yellow)
                    Text("Osiągnięcia")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(vm.unlockedAchievements.count)/\(vm.achievements.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                ProgressView(
                    value: Double(vm.unlockedAchievements.count),
                    total: Double(max(vm.achievements.count, 1))
                )
                .tint(.yellow)

                if !vm.unlockedAchievements.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(vm.unlockedAchievements.prefix(5)) { ach in
                            Image(systemName: ach.icon)
                                .font(.subheadline)
                                .foregroundStyle(ach.swiftUIColor)
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(ach.swiftUIColor.opacity(0.15)))
                        }
                        Spacer()
                        if vm.unlockedAchievements.count > 5 {
                            Text("+\(vm.unlockedAchievements.count - 5)")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .appCard(tint: .yellow)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sklep, jedno zadanie
    private var navigationCards: some View {
        VStack(spacing: 12) {
            Button { showShop = true } label: {
                navigationRow(
                    icon: "bag.fill", color: .purple,
                    title: "Sklep",
                    subtitle: "Wydaj \(vm.gold) złota na nagrody"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                OneTaskView(vm: vm)
            } label: {
                navigationRow(
                    icon: "scope", color: .teal,
                    title: "Jedno zadanie",
                    subtitle: "Tylko jedno zadanie naraz, bez rozpraszaczy"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func navigationRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(Circle().fill(color.opacity(0.15)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .appCard(tint: color)
    }

    // MARK: - Nastrój
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Jak się czujesz?", systemImage: "face.smiling")
            HStack(spacing: 8) {
                ForEach(MoodLevel.allCases) { mood in
                    let isSelected = vm.currentMood == mood
                    Button {
                        Haptics.tap()
                        vm.logMood(mood)
                    } label: {
                        VStack(spacing: 4) {
                            Text(mood.rawEmoji).font(.title2)
                            Text(mood.rawValue)
                                .font(.caption2)
                                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(isSelected ? Color.accentColor.opacity(0.14) : Color(.systemFill))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(isSelected ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(mood.rawValue)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    // MARK: - Reset
    private var dangerZone: some View {
        Button { showResetAlert = true } label: {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                Text("Resetuj wszystko")
                    .font(.subheadline.bold())
                    .foregroundStyle(.red)
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.red.opacity(0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.red.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.bottom, 24)
    }
}
