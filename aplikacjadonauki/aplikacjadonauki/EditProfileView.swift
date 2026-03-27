import SwiftUI

struct EditProfileView: View {
    @ObservedObject var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name  = ""
    @State private var emoji = ""

    private let avatarOptions = ["🧹", "🧙", "🦸", "🐱", "🐶", "🦊", "🐉", "🤖", "👾", "🌟"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Nazwa gracza") {
                    TextField("Twoja nazwa", text: $name)
                }
                Section("Avatar") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 5),
                        spacing: 12
                    ) {
                        ForEach(avatarOptions, id: \.self) { av in
                            Button { emoji = av } label: {
                                Text(av)
                                    .font(.largeTitle)
                                    .padding(8)
                                    .background(
                                        Circle().fill(emoji == av
                                                       ? Color.blue.opacity(0.2)
                                                       : Color.clear)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                Section("Tytuł") {
                    Picker("Wybierz tytuł", selection: Binding(
                        get: { vm.profile.selectedTitle ?? vm.profile.earnedTitle },
                        set: { vm.profile.selectedTitle = $0 }
                    )) {
                        ForEach(vm.profile.unlockedTitles, id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                }
            }
            .navigationTitle("Edytuj profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Zapisz") {
                        if !name.isEmpty { vm.updatePlayerName(name) }
                        if !emoji.isEmpty { vm.updatePlayerAvatar(emoji) }
                        dismiss()
                    }
                    .bold()
                }
            }
            .onAppear {
                name  = vm.profile.name
                emoji = vm.profile.avatarEmoji
            }
        }
    }
}
