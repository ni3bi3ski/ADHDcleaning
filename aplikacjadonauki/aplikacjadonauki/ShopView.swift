import SwiftUI

struct ShopView: View {
    @ObservedObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showAddItem       = false
    @State private var selectedCategory: ShopCategory? = nil

    private var filteredItems: [ShopItem] {
        guard let cat = selectedCategory else { return vm.shopItems }
        return vm.shopItems.filter { $0.category == cat }
    }

    private var groupedItems: [(ShopCategory, [ShopItem])] {
        if let cat = selectedCategory {
            let items = vm.shopItems.filter { $0.category == cat }
            return items.isEmpty ? [] : [(cat, items)]
        }
        return ShopCategory.allCases.compactMap { cat in
            let items = vm.shopItems.filter { $0.category == cat }
            return items.isEmpty ? nil : (cat, items)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    goldCard
                    categoryFilter
                    ForEach(groupedItems, id: \.0.rawValue) { group in
                        shopSection(category: group.0, items: group.1)
                    }
                }
                .padding(.vertical, 16)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Sklep 🛍️")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Zamknij") { dismiss() }
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddItem = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddShopItemView(vm: vm)
            }
        }
    }

    // MARK: - Gold Card
    private var goldCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 52, height: 52)
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Twoje złoto")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(vm.gold) 🪙")
                    .font(.title2).bold()
            }

            Spacer()

            if let next = vm.shopItems.filter({ !$0.isPurchased && vm.gold < $0.cost })
                .sorted(by: { $0.cost < $1.cost }).first {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Brakuje")
                        .font(.caption2).foregroundStyle(.secondary)
                    Text("\(next.cost - vm.gold) 🪙")
                        .font(.caption).bold()
                        .foregroundColor(.orange)
                    Text("do: \(next.title)")
                        .font(.caption2).foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .yellow.opacity(0.2), radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [.yellow.opacity(0.4), .orange.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal)
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = nil
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.caption)
                        Text("Wszystkie")
                            .font(.caption).bold()
                    }
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(
                        Capsule().fill(selectedCategory == nil
                            ? Color.blue : Color(.systemFill))
                    )
                    .foregroundColor(selectedCategory == nil ? .white : .primary)
                }
                .buttonStyle(.plain)

                ForEach(ShopCategory.allCases, id: \.self) { cat in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = (selectedCategory == cat) ? nil : cat
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: cat.icon)
                                .font(.caption)
                            Text(cat.rawValue)
                                .font(.caption).bold()
                        }
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(
                            Capsule().fill(selectedCategory == cat
                                ? cat.swiftUIColor : Color(.systemFill))
                        )
                        .foregroundColor(selectedCategory == cat ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Shop Section
    private func shopSection(category: ShopCategory, items: [ShopItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.caption).bold()
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(category.swiftUIColor))
                Text(category.rawValue)
                    .font(.subheadline).bold()
                Spacer()
                Text("\(items.filter { $0.isPurchased }.count)/\(items.count)")
                    .font(.caption).bold()
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(Color(.systemFill)))
            }
            .padding(.horizontal, 16)

            VStack(spacing: 8) {
                ForEach(items) { item in
                    ShopItemRow(item: item, gold: vm.gold) {
                        withAnimation(.spring(response: 0.3)) {
                            if item.isPurchased {
                                vm.resetShopItem(item)
                            } else {
                                vm.buyItem(item)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Shop Item Row
private struct ShopItemRow: View {
    let item: ShopItem
    let gold: Int
    let onTap: () -> Void

    var canAfford: Bool { gold >= item.cost }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.isPurchased
                          ? Color.green.opacity(0.15)
                          : item.category.swiftUIColor.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: item.icon)
                    .font(.title3)
                    .foregroundColor(item.isPurchased ? .green : item.category.swiftUIColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.body).bold()
                    .strikethrough(item.isPurchased, color: .secondary)
                    .foregroundColor(item.isPurchased ? .secondary : .primary)

                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text("\(item.cost) złota")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if item.isConsumable {
                        Text("· jednorazowy")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()

            Button(action: onTap) {
                if item.isPurchased {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Użyte")
                    }
                    .font(.caption).bold()
                    .foregroundColor(.green)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(Color.green.opacity(0.15)))
                } else {
                    Text(canAfford ? "Kup" : "Za mało")
                        .font(.caption).bold()
                        .foregroundColor(canAfford ? .white : .secondary)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(
                            Capsule().fill(canAfford
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing))
                                : AnyShapeStyle(Color(.systemFill)))
                        )
                }
            }
            .buttonStyle(.plain)
            .disabled(!canAfford && !item.isPurchased)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
        .opacity((!canAfford && !item.isPurchased) ? 0.6 : 1.0)
    }
}

// MARK: - ShopCategory helpers
extension ShopCategory {
    var icon: String {
        switch self {
        case .reward: return "gift.fill"
        case .pet:    return "pawprint.fill"
        case .skill:  return "bolt.circle.fill"
        case .item:   return "backpack.fill"
        case .potion: return "heart.fill"
        case .avatar: return "tshirt.fill"
        }
    }

    var swiftUIColor: Color {
        switch self {
        case .reward: return .purple
        case .pet:    return .pink
        case .skill:  return .blue
        case .item:   return .orange
        case .potion: return .red
        case .avatar: return .teal
        }
    }
}

// MARK: - Dodaj własną nagrodę
struct AddShopItemView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: AppViewModel
    @State private var title        = ""
    @State private var cost         = 50
    @State private var selectedIcon = "gift.fill"

    let icons = [
        "gift.fill", "tv.fill", "gamecontroller.fill", "cup.and.saucer.fill",
        "birthday.cake.fill", "flame.fill", "cart.fill", "heart.fill",
        "music.note", "book.fill", "airplane", "figure.walk",
        "camera.fill", "headphones", "bicycle", "bed.double.fill",
        "fork.knife", "car.fill", "ticket.fill", "bag.fill",
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Nagroda") {
                    TextField("Nazwa nagrody", text: $title)
                    Stepper("Koszt: \(cost) 🪙", value: $cost, in: 10...1000, step: 10)
                }

                Section("Ikona") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedIcon == icon
                                                  ? Color.yellow.opacity(0.3)
                                                  : Color(.systemFill))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(selectedIcon == icon
                                                          ? Color.yellow : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Nowa nagroda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Dodaj") {
                        let t = title.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { return }
                        vm.addCustomShopItem(title: t, icon: selectedIcon, cost: cost)
                        dismiss()
                    }
                    .bold()
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
