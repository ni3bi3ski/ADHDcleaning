import SwiftUI

struct AddCustomTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: AppViewModel

    @State private var title: String = ""
    @State private var category: TaskCategory = .custom
    @State private var difficulty: TaskDifficulty = .easy
    @State private var frequency: TaskFrequency = .daily

    private var previewXP: Int {
        let task = CleaningTask(
            title: "",
            category: category,
            difficulty: difficulty,
            frequency: frequency
        )
        return task.exp
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Zadanie") {
                    TextField("Nazwa zadania", text: $title)
                }

                Section("Częstotliwość") {
                    Picker("Częstotliwość", selection: $frequency) {
                        ForEach(TaskFrequency.allCases, id: \.self) { f in
                            Label(f.rawValue, systemImage: f.icon).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Kategoria") {
                    Picker("Kategoria", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("Trudność") {
                    Picker("Trudność", selection: $difficulty) {
                        ForEach(TaskDifficulty.allCases, id: \.self) { d in
                            Text("\(d.icon) \(d.rawValue)").tag(d)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    HStack {
                        Text("XP za zadanie")
                        Spacer()
                        Text("\(previewXP) XP")
                            .bold()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                } footer: {
                    Text("XP zależy od częstotliwości i trudności zadania.")
                        .font(.caption)
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
                        let trimmed = title.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        vm.addCustomTask(
                            title: trimmed,
                            category: category,
                            difficulty: difficulty,
                            frequency: frequency
                        )
                        dismiss()
                    }
                    .bold()
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
