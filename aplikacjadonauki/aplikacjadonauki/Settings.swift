import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsStore
    @ObservedObject var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showResetConfirm = false

    let availableColors: [(name: String, color: Color)] = [
        ("Niebieski",    .blue),
        ("Fioletowy",    .purple),
        ("Różowy",       .pink),
        ("Czerwony",     .red),
        ("Pomarańczowy", .orange),
        ("Żółty",        .yellow),
        ("Zielony",      .green),
        ("Miętowy",      .mint),
        ("Turkusowy",    .teal),
        ("Indygo",       .indigo)
    ]

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Kolor akcentu
                Section("Kolor akcentu") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(availableColors, id: \.name) { item in
                                Button {
                                    settings.accentColorName = item.name
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(item.color)
                                            .frame(width: 36, height: 36)
                                        if settings.accentColorName == item.name {
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                // MARK: - Profil
                Section("Profil") {
                    HStack {
                        Label("Gracz", systemImage: "person.fill")
                        Spacer()
                        Text(vm.profile.name)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Poziom", systemImage: "bolt.fill")
                        Spacer()
                        Text("\(vm.level)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Gold", systemImage: "dollarsign.circle.fill")
                        Spacer()
                        Text("\(vm.gold) 🪙")
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Dane
                Section("Dane") {
                    NavigationLink {
                        BackupScreen(vm: vm)
                    } label: {
                        Label("Kopia zapasowa i tryb choroby", systemImage: "externaldrive.fill")
                    }
                }

                // MARK: - Aplikacja
                Section("Aplikacja") {
                    HStack {
                        Label("Wersja", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Danger Zone
                Section {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("Resetuj wszystkie dane", systemImage: "trash.fill")
                    }
                } header: {
                    Text("Strefa niebezpieczna")
                } footer: {
                    Text("Ta operacja jest nieodwracalna. Wszystkie zadania, XP, gold, osiągnięcia i profil zostaną usunięte.")
                }
            }
            .navigationTitle("Ustawienia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Gotowe") { dismiss() }
                        .bold()
                }
            }
            .confirmationDialog(
                "Resetować wszystkie dane?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Resetuj", role: .destructive) {
                    vm.resetAll()
                    dismiss()
                }
                Button("Anuluj", role: .cancel) {}
            } message: {
                Text("Stracisz cały postęp, XP i gold.")
            }
        }
    }
}
