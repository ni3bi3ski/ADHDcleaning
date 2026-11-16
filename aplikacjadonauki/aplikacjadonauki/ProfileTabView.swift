import SwiftUI

struct ProfileTabView: View {
    @ObservedObject var vm: AppViewModel
    @State private var showShop         = false
    @State private var showAchievements = false
    @State private var showEditProfile  = false
    @State private var showResetAlert   = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    quickStatsRow
                    challengeSection
                    achievementsPreview
                    shopButton
                    oneTaskButton
                    moodSection
                    dangerZone
                }
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3).foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showShop)         { ShopView(vm: vm) }
            .sheet(isPresented: $showAchievements) { AchievementsView(vm: vm) }
            .sheet(isPresented: $showEditProfile)  { EditProfileView(vm: vm) }
            .alert("Reset wszystkiego?", isPresented: $showResetAlert) {
                Button("Resetuj", role: .destructive) { vm.resetAll() }
                Button("Anuluj", role: .cancel) {}
            } message: {
                Text("Stracisz cały postęp, XP, gold i osiągnięcia. Nie można cofnąć!")
            }
        }
    }

    // MARK: - Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                Text(vm.profile.avatarEmoji)
                    .font(.system(size: 44))
            }
            Text(vm.profile.name)
                .font(.title2).bold()
            Text(vm.profile.displayTitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(vm.profile.playerClass.icon + " " + vm.profile.playerClass.rawValue)
                .font(.caption).bold()
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(Capsule().fill(Color.blue.opacity(0.1)))
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Quick Stats
    private var quickStatsRow: some View {
        HStack(spacing: 0) {
            StatPill(
                icon: "checkmark.circle.fill",
                color: .green,
                label: "Zadań",
                value: "\(vm.profile.totalTasksCompleted)"
            )
            Divider().frame(height: 40)
            StatPill(
                icon: "flame.fill",
                color: .orange,
                label: "Streak",
                value: "\(vm.streak)"
            )
            Divider().frame(height: 40)
            StatPill(
                icon: "dollarsign.circle.fill",
                color: .yellow,
                label: "Gold",
                value: "\(vm.gold)"
            )
            Divider().frame(height: 40)
            StatPill(
                icon: "star.fill",
                color: .purple,
                label: "Poziom",
                value: "\(vm.level)"
            )
        }
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }


    // MARK: - Challenge
    @ViewBuilder
    private var challengeSection: some View {
        if let challenge = vm.weeklyChallenge {
            WeeklyChallengeCardView(challenge: challenge)
                .padding(.horizontal)
        }
    }

    // MARK: - Achievements Preview
    private var achievementsPreview: some View {
        Button { showAchievements = true } label: {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "trophy.fill").foregroundColor(.yellow)
                    Text("Osiągnięcia")
                        .font(.headline).bold().foregroundColor(.primary)
                    Spacer()
                    Text("\(vm.unlockedAchievements.count)/\(vm.achievements.count)")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                }
                ProgressView(
                    value: Double(vm.unlockedAchievements.count),
                    total: Double(max(vm.achievements.count, 1))
                ).tint(.yellow)

                // Ostatnio odblokowane (max 3)
                if !vm.unlockedAchievements.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(vm.unlockedAchievements.prefix(5)) { ach in
                            Text(ach.icon)
                                .font(.title3)
                                .padding(6)
                                .background(Circle().fill(Color.yellow.opacity(0.1)))
                        }
                        Spacer()
                        if vm.unlockedAchievements.count > 5 {
                            Text("+\(vm.unlockedAchievements.count - 5)")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
            .shadow(color: .yellow.opacity(0.1), radius: 6, x: 0, y: 2)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.yellow.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    // MARK: - Shop
    private var shopButton: some View {
        Button { showShop = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "bag.fill").font(.title3).foregroundColor(.purple)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sklep").font(.headline).bold().foregroundColor(.primary)
                    Text("Wydaj \(vm.gold) złota na nagrody")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
            .shadow(color: .purple.opacity(0.1), radius: 6, x: 0, y: 2)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.purple.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    // MARK: - Tryb jednego zadania
    private var oneTaskButton: some View {
        NavigationLink {
            OneTaskView(vm: vm)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "scope").font(.title3).foregroundColor(.teal)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Jedno zadanie").font(.headline).bold().foregroundColor(.primary)
                    Text("Tylko jedno zadanie naraz, bez rozpraszaczy")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
            .shadow(color: .teal.opacity(0.1), radius: 6, x: 0, y: 2)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.teal.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    // MARK: - Mood
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Jak się czujesz?").font(.headline).bold()
            HStack(spacing: 8) {
                ForEach(MoodLevel.allCases) { mood in
                    Button { vm.logMood(mood) } label: {
                        VStack(spacing: 4) {
                            Text(mood.rawEmoji).font(.title2)
                            Text(mood.rawValue)
                                .font(.caption2)
                                .foregroundStyle(vm.currentMood == mood
                                                 ? Color.primary : Color.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(vm.currentMood == mood
                                      ? Color.blue.opacity(0.12) : Color(.systemFill))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    vm.currentMood == mood
                                        ? Color.blue.opacity(0.4) : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Danger Zone
    private var dangerZone: some View {
        Button { showResetAlert = true } label: {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                Text("Resetuj wszystko").font(.subheadline).bold().foregroundColor(.red)
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.red.opacity(0.06)))
            .overlay(RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.red.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
}
