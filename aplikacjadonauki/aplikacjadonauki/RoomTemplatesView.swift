import SwiftUI

struct RoomTemplatesView: View {
    @ObservedObject var vm: AppViewModel
    @State private var message: String?

    var body: some View {
        List {
            ForEach(RoomTemplate.all) { template in
                Section {
                    ForEach(template.tasks, id: \.title) { item in
                        HStack {
                            Image(systemName: item.category.icon)
                                .foregroundStyle(.secondary)
                            Text(item.title)
                            Spacer()
                            Text(item.frequency.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Button {
                        let added = vm.addTemplate(template)
                        Haptics.success()
                        message = added > 0
                            ? "Dodano \(added) zadań z szablonu: \(template.name)."
                            : "Wszystkie zadania z szablonu \(template.name) już masz."
                    } label: {
                        Label("Dodaj do moich zadań", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("\(template.icon) \(template.name)")
                }
            }

            if let message {
                Section { Text(message).font(.footnote) }
            }
        }
        .navigationTitle("Szablony zadań")
    }
}
