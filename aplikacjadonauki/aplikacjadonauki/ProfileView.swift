import SwiftUI

struct ProfileView: View {
    @ObservedObject var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isEditingName    = false
    @State private var isEditingBio     = false
    @State private var editName         = ""
    @State private var editBio          = ""
    @State private var showAvatarPicker = false
    @State private var showTitlePicker  = false
    @State private var showColorPicker  = false
    @State private var showClassPicker  = false
    @State private var showDressingRoom = false   // ← NOWE

    private var accentColor: Color {
        Color.appColor(named: vm.profile.accentColorName)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    avatarCard
                    avatarDressingButton        // ← NOWE
                    habitTracker
                    lifetimeStats
                    categoryStats
                    showcaseSection
                    customizationSection
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Gotowe") { dismiss() }
                }
            }
            .sheet(isPresented: $showAvatarPicker) {
                AvatarPickerView(selected: $vm.profile.avatarEmoji)
            }
            .sheet(isPresented: $showTitlePicker) {
                TitlePickerView(vm: vm)
            }
            .sheet(isPresented: $showColorPicker) {
                AccentColorPickerView(selected: $vm.profile.accentColorName)
            }
            .sheet(isPresented: $showClassPicker) {
                ClassPickerView(vm: vm)
            }
            .sheet(isPresented: $showDressingRoom) {  // ← NOWE
                AvatarDressingRoomView(vm: vm)
            }
        }
    }

    // MARK: - Avatar Card
    private var avatarCard: some View {
        VStack(spacing: 16) {
            ZStack {
                if vm.isMasterLevel {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                                center: .center
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 96, height: 96)
                } else {
                    Circle()
                        .stroke(Color.appColor(named: PlayerProfile.frameColor(for: vm.level)),
                                lineWidth: 4)
                        .frame(width: 96, height: 96)
                }

                Button { showAvatarPicker = true } label: {
                    ZStack(alignment: .bottomTrailing) {
                        Text(vm.profile.avatarEmoji)
                            .font(.system(size: 52))
                            .frame(width: 80, height: 80)
                            .background(Circle().fill(accentColor.opacity(0.12)))
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(accentColor)
                            .background(Circle().fill(Color(.systemBackground)))
                            .font(.title3)
                    }
                }
                .buttonStyle(.plain)
            }

            // Imię
            Group {
                if isEditingName {
                    HStack {
                        TextField("Imię", text: $editName)
                            .font(.title2).bold()
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 200)
                        Button {
                            vm.profile.name = editName
                            isEditingName = false
                            vm.saveToCloud()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green).font(.title2)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Button {
                        editName = vm.profile.name
                        isEditingName = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(vm.profile.name)
                                .font(.title2).bold()
                                .foregroundColor(.primary)
                            Image(systemName: "pencil").font(.caption).foregroundColor(accentColor)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            // Tytuł
            Button { showTitlePicker = true } label: {
                HStack(spacing: 6) {
                    Text(vm.profile.displayTitle)
                        .font(.subheadline).bold()
                        .foregroundColor(accentColor)
                    Image(systemName: "chevron.down").font(.caption2).foregroundColor(accentColor)
                }
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(Capsule().fill(accentColor.opacity(0.12)))
            }
            .buttonStyle(.plain)

            // Klasa gracza
            Button { showClassPicker = true } label: {
                HStack(spacing: 6) {
                    Text(vm.profile.playerClass.icon)
                    Text(vm.profile.playerClass.rawValue)
                        .font(.caption).bold()
                        .foregroundColor(accentColor)
                    Text("·").foregroundStyle(.tertiary)
                    Text(vm.profile.playerClass.description)
                        .font(.caption).foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(accentColor.opacity(0.08)))
                .overlay(Capsule().strokeBorder(accentColor.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(.plain)

            // Bio
            if isEditingBio {
                VStack(spacing: 8) {
                    TextField("Bio (max 60 znaków)", text: $editBio)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: editBio) { _, new in
                            if new.count > 60 { editBio = String(new.prefix(60)) }
                        }
                    HStack(spacing: 12) {
                        Button("Anuluj") { isEditingBio = false }
                            .foregroundColor(.secondary)
                        Button("Zapisz") {
                            vm.profile.bio = editBio
                            isEditingBio = false
                            vm.saveToCloud()
                        }
                        .foregroundColor(accentColor).bold()
                    }
                    .font(.subheadline)
                    Text("\(editBio.count)/60").font(.caption2).foregroundStyle(.tertiary)
                }
            } else {
                Button {
                    editBio = vm.profile.bio
                    isEditingBio = true
                } label: {
                    Text(vm.profile.bio.isEmpty ? "Dodaj bio..." : vm.profile.bio)
                        .font(.subheadline)
                        .foregroundStyle(vm.profile.bio.isEmpty ? .tertiary : .secondary)
                        .multilineTextAlignment(.center)
                        .italic(vm.profile.bio.isEmpty)
                }
                .buttonStyle(.plain)
            }

            // Lvl + Seria + HP
            HStack(spacing: 20) {
                StatPill(icon: "star.fill", color: accentColor,
                         label: "Poziom", value: "\(vm.level)")
                StatPill(icon: "flame.fill", color: .orange,
                         label: "Seria", value: "\(vm.streak) tyg.")
                StatPill(icon: "heart.fill", color: vm.playerHP < 30 ? .red : .green,
                         label: "HP", value: "\(vm.playerHP)")
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
        .shadow(color: accentColor.opacity(0.1), radius: 12, x: 0, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 20)
            .strokeBorder(accentColor.opacity(0.15), lineWidth: 1))
        .padding(.horizontal)
    }

    // MARK: - Avatar Dressing Button (NOWE)
    private var avatarDressingButton: some View {
        Button { showDressingRoom = true } label: {
            HStack(spacing: 14) {
                // Miniaturka awatara
                AvatarView(equipped: vm.profile.equippedAvatar, size: 52)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Mój awatar")
                        .font(.subheadline).bold()
                    let equippedCount = vm.profile.equippedAvatar.keys
                        .filter { $0 != .body }.count
                    Text(equippedCount > 0
                         ? "\(equippedCount) elementów ubrania"
                         : "Kup ubrania w Sklepie 🛍️")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("Szatnia")
                        .font(.caption).bold()
                        .foregroundColor(accentColor)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(accentColor)
                }
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(accentColor.opacity(0.12)))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: accentColor.opacity(0.08), radius: 6, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(accentColor.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    // MARK: - Habit Tracker
    private var habitTracker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.checkmark").foregroundColor(accentColor)
                Text("Ostatnie 7 dni").font(.headline).bold()
                Spacer()
                Text("\(vm.profile.last7DaysActivity.filter { $0 }.count)/7")
                    .font(.caption).bold()
                    .foregroundColor(accentColor)
            }

            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { i in
                    let active = i < vm.profile.last7DaysActivity.count
                        ? vm.profile.last7DaysActivity[i] : false
                    let label = dayLabel(for: i)
                    VStack(spacing: 4) {
                        Circle()
                            .fill(active ? accentColor : Color(.systemFill))
                            .frame(width: 32, height: 32)
                            .overlay(
                                active
                                    ? Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .eraseToAnyView()
                                    : Circle().fill(Color.clear).eraseToAnyView()
                            )
                        Text(label).font(.caption2).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            if vm.profile.consecutiveDailyDays > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill").foregroundColor(.orange).font(.caption)
                    Text("Aktualny streak dzienny: \(vm.profile.consecutiveDailyDays) dni")
                        .font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text("Rekord: \(vm.profile.longestStreak) dni")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Lifetime Stats
    private var lifetimeStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill").foregroundColor(accentColor)
                Text("Statystyki lifetime").font(.headline).bold()
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                LifetimeStatCard(icon: "checkmark.circle.fill", color: .green,
                                 label: "Zadania", value: "\(vm.profile.totalTasksCompleted)")
                LifetimeStatCard(icon: "bolt.fill", color: .blue,
                                 label: "XP total", value: "\(vm.experience)")
                LifetimeStatCard(icon: "dollarsign.circle.fill", color: .yellow,
                                 label: "Gold earned", value: "\(vm.profile.totalGoldEarned)")
                LifetimeStatCard(icon: "flame.fill", color: .orange,
                                 label: "Najdł. seria", value: "\(vm.profile.longestStreak) tyg.")
                LifetimeStatCard(icon: "bolt.fill", color: accentColor,
                                 label: "Wyzwania", value: "\(vm.profile.challengesCompleted)")
                if let fav = vm.profile.favoriteCategory {
                    LifetimeStatCard(icon: fav.icon, color: fav.swiftUIColor,
                                     label: "Ulubiona kat.", value: fav.rawValue)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Category Stats
    private var categoryStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.grid.3x3.fill").foregroundColor(accentColor)
                Text("Zadania per kategoria").font(.headline).bold()
            }

            let items: [(TaskCategory, Int)] = [
                (.kitchen,  vm.profile.kitchenTasksCompleted),
                (.bathroom, vm.profile.bathroomTasksCompleted),
                (.health,   vm.profile.healthTasksCompleted),
                (.fitness,  vm.profile.fitnessTasksCompleted),
                (.focus,    vm.profile.focusTasksCompleted),
                (.finance,  vm.profile.financeTasksCompleted),
                (.social,   vm.profile.socialTasksCompleted),
                (.selfcare, vm.profile.selfcareTasksCompleted),
                (.work,     vm.profile.workTasksCompleted),
            ]
            let maxVal = items.map { $0.1 }.max() ?? 1

            VStack(spacing: 8) {
                ForEach(items.filter { $0.1 > 0 }, id: \.0) { cat, count in
                    HStack(spacing: 10) {
                        Image(systemName: cat.icon)
                            .font(.caption).foregroundColor(cat.swiftUIColor)
                            .frame(width: 20)
                        Text(cat.rawValue)
                            .font(.caption).bold()
                            .frame(width: 80, alignment: .leading)
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(cat.swiftUIColor.opacity(0.2))
                                .frame(height: 14)
                                .overlay(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(cat.swiftUIColor)
                                        .frame(
                                            width: geo.size.width * (Double(count) / Double(max(maxVal, 1))),
                                            height: 14
                                        )
                                        .animation(.spring(response: 0.5), value: count)
                                }
                        }
                        .frame(height: 14)
                        Text("\(count)")
                            .font(.caption).bold()
                            .foregroundStyle(.secondary)
                            .frame(width: 28, alignment: .trailing)
                    }
                }
                if items.allSatisfy({ $0.1 == 0 }) {
                    Text("Ukończ zadania żeby zobaczyć statystyki!")
                        .font(.subheadline).foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Showcase
    private var showcaseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.square.on.square.fill").foregroundColor(accentColor)
                Text("Osiągnięcia – showcase").font(.headline).bold()
                Spacer()
                Text("\(vm.unlockedAchievements.count)/\(vm.achievements.count)")
                    .font(.caption).bold().foregroundColor(accentColor)
            }

            if vm.unlockedAchievements.isEmpty {
                Text("Ukończ zadania żeby odblokować osiągnięcia!")
                    .font(.subheadline).foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else {
                let recent = Array(vm.unlockedAchievements
                    .sorted { ($0.unlockedDate ?? .distantPast) > ($1.unlockedDate ?? .distantPast) }
                    .prefix(3))
                HStack(spacing: 12) {
                    ForEach(recent) { ach in
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(ach.swiftUIColor.opacity(0.15))
                                    .frame(width: 56, height: 56)
                                Image(systemName: ach.icon)
                                    .font(.title2)
                                    .foregroundColor(ach.swiftUIColor)
                            }
                            Text(ach.title)
                                .font(.caption2).bold()
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(width: 70)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    ForEach(0..<(3 - recent.count), id: \.self) { _ in
                        VStack(spacing: 6) {
                            Circle()
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundColor(Color(.systemFill))
                                .frame(width: 56, height: 56)
                            Text("Zablokowane")
                                .font(.caption2).foregroundStyle(.tertiary)
                                .frame(width: 70)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Customization
    private var customizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "paintbrush.fill").foregroundColor(accentColor)
                Text("Personalizacja").font(.headline).bold()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Kolor motywu").font(.subheadline).bold()
                HStack(spacing: 10) {
                    ForEach(["blue","purple","green","orange","pink","teal","red","indigo"], id: \.self) { name in
                        let col = Color.appColor(named: name)
                        Button {
                            vm.profile.accentColorName = name
                            vm.saveToCloud()
                        } label: {
                            Circle()
                                .fill(col)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle().strokeBorder(.white, lineWidth:
                                        vm.profile.accentColorName == name ? 3 : 0)
                                )
                                .shadow(color: col.opacity(0.4), radius: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemFill)))
            }

            if !vm.profile.pets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Twoje pety").font(.subheadline).bold()
                    HStack(spacing: 8) {
                        ForEach(vm.profile.pets) { pet in
                            VStack(spacing: 2) {
                                Text(pet.icon).font(.title2)
                                Text("Lvl \(pet.level)")
                                    .font(.caption2).bold()
                                    .foregroundColor(accentColor)
                            }
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .fill(accentColor.opacity(0.08)))
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemFill)))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Danger zone").font(.subheadline).bold().foregroundColor(.red)
                Button {
                    vm.resetAll()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "trash.fill").foregroundColor(.red)
                        Text("Zresetuj wszystko").foregroundColor(.red).bold()
                        Spacer()
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.08)))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.red.opacity(0.2), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemFill)))
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Helper
    private func dayLabel(for index: Int) -> String {
        let days = ["Pn","Wt","Śr","Cz","Pt","Sb","Nd"]
        let today = Calendar.current.component(.weekday, from: Date())
        let todayIdx = (today + 5) % 7
        let dayIdx = (todayIdx - 6 + index + 7) % 7
        return days[dayIdx]
    }
}

// MARK: - Class Picker
struct ClassPickerView: View {
    @ObservedObject var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(PlayerClass.allCases, id: \.self) { playerClass in
                    Button {
                        withAnimation {
                            vm.profile.playerClass = playerClass
                            vm.saveToCloud()
                        }
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            Text(playerClass.icon)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemFill)))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(playerClass.rawValue)
                                    .font(.subheadline).bold()
                                    .foregroundColor(.primary)
                                Text(playerClass.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if vm.profile.playerClass == playerClass {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Wybierz klasę")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Avatar Picker
struct AvatarPickerView: View {
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss

    private let avatars = [
        "🧹","🧽","🧴","🪣","🧺","🛁",
        "🦸","🦹","🧙","🧝","🧛","🤖",
        "🐱","🐶","🦊","🐺","🦁","🐯",
        "🌟","⚡","🔥","💎","👑","🏆",
        "🧠","💪","🎯","⚔️","🛡️","🎮",
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                    ForEach(avatars, id: \.self) { emoji in
                        Button {
                            selected = emoji
                            dismiss()
                        } label: {
                            Text(emoji)
                                .font(.system(size: 40))
                                .frame(width: 64, height: 64)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(selected == emoji
                                              ? Color.blue.opacity(0.2) : Color(.systemFill))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(selected == emoji
                                                      ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Wybierz awatara")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Title Picker
struct TitlePickerView: View {
    @ObservedObject var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.profile.unlockedTitles, id: \.self) { title in
                    Button {
                        vm.profile.selectedTitle = title
                        vm.saveToCloud()
                        dismiss()
                    } label: {
                        HStack {
                            Text(title).font(.subheadline).bold()
                                .foregroundColor(.primary)
                            Spacer()
                            if vm.profile.displayTitle == title {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Wybierz tytuł")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Accent Color Picker
struct AccentColorPickerView: View {
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss

    private let colors = ["blue","purple","green","orange","pink","teal","red","indigo","mint","yellow"]

    var body: some View {
        NavigationStack {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 20) {
                ForEach(colors, id: \.self) { name in
                    let col = Color.appColor(named: name)
                    Button {
                        selected = name
                        dismiss()
                    } label: {
                        Circle()
                            .fill(col)
                            .frame(width: 48, height: 48)
                            .overlay(Circle()
                                .strokeBorder(.white, lineWidth: selected == name ? 3 : 0))
                            .shadow(color: col.opacity(0.4), radius: 6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(30)
            .navigationTitle("Kolor motywu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Pomocnicze komponenty
struct StatPill: View {
    let icon: String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon).foregroundColor(color).font(.caption)
            Text(value).font(.subheadline).bold()
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.08)))
    }
}

struct LifetimeStatCard: View {
    let icon: String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(color).font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(value).font(.subheadline).bold()
                Text(label).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemFill)))
    }
}

// MARK: - AnyView helper
extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}
