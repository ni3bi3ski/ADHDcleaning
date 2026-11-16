import SwiftUI

struct ShopView: View {
    @ObservedObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showAddItem       = false
    @State private var selectedCategory: ShopCategory? = nil

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
                VStack(spacing: 16) {
                    goldCard
                    categoryFilter
                    ForEach(groupedItems, id: \.0.rawValue) { group in
                        shopSection(category: group.0, items: group.1)
                    }
                }
                .frame(maxWidth: 640)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Sklep")
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
                    .accessibilityLabel("Dodaj własną nagrodę")
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddShopItemView(vm: vm)
            }
        }
    }

    // MARK: - Złoto
    private var goldCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(
                    Circle().fill(LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Twoje złoto")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(vm.gold)")
                    .font(.system(size: 30, weight: .bold, design: .rounded).monospacedDigit())
            }

            Spacer()

            if let next = vm.shopItems.filter({ !$0.isPurchased && vm.gold < $0.cost })
                .sorted(by: { $0.cost < $1.cost }).first {
                VStack(alignment: .trailing, spacing: 4) {
                    StatusChip(text: "Brakuje \(next.cost - vm.gold)", icon: "dollarsign.circle.fill", color: .orange)
                    Text("do: \(next.title)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .appCard(tint: .yellow)
    }

    // MARK: - Filtr kategorii
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(
                    title: "Wszystkie", icon: "square.grid.2x2.fill",
                    color: .accentColor, isSelected: selectedCategory == nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = nil }
                }

                ForEach(ShopCategory.allCases, id: \.self) { cat in
                    filterChip(
                        title: cat.rawValue, icon: cat.icon,
                        color: cat.swiftUIColor, isSelected: selectedCategory == cat
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = (selectedCategory == cat) ? nil : cat
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func filterChip(title: String, icon: String, color: Color,
                            isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption.bold())
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(
                    Capsule().fill(isSelected ? color : Color(.secondarySystemGroupedBackground))
                )
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sekcja kategorii
    private func shopSection(category: ShopCategory, items: [ShopItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(category.swiftUIColor))
                Text(category.rawValue)
                    .font(.headline)
                Spacer()
                Text("\(items.filter { $0.isPurchased }.count)/\(items.count)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(Color(.systemFill)))
            }
            .padding(.horizontal, 4)

            VStack(spacing: 10) {
                ForEach(items) { item in
                    ShopItemRow(item: item, gold: vm.gold) {
                        Haptics.tap()
                        withAnimation(.spring(response: 0.3)) {
                            if item.isPurchased {
                                if item.canRepurchase { vm.resetShopItem(item) }
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

// MARK: - Możliwość ponownego zakupu
fileprivate extension ShopItem {
    /// Nagrody, własne przedmioty i eliksiry można kupować wielokrotnie.
    /// Pety, umiejętności, przedmioty i ubrania kupuje się raz.
    var canRepurchase: Bool {
        category == .reward || isCustom || isConsumable
    }
}

// MARK: - Wiersz produktu
private struct ShopItemRow: View {
    let item: ShopItem
    let gold: Int
    let onTap: () -> Void

    var canAfford: Bool { gold >= item.cost }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.icon)
                .font(.title3)
                .foregroundStyle(item.isPurchased ? Color.green : item.category.swiftUIColor)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill((item.isPurchased ? Color.green : item.category.swiftUIColor).opacity(0.14))
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(item.isPurchased ? Color.secondary : Color.primary)
                    .fixedSize(horizontal: false, vertical: true)

                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 6) {
                    Label("\(item.cost)", systemImage: "dollarsign.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.yellow)
                    if item.isConsumable {
                        Text("jednorazowy")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer(minLength: 8)

            Button(action: onTap) {
                if item.isPurchased {
                    StatusChip(
                        text: item.category == .reward ? "Odebrane" : "Kupione",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                } else {
                    Text(canAfford ? "Kup" : "Za mało")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .foregroundColor(canAfford ? .white : .secondary)
                        .background(
                            Capsule().fill(
                                canAfford
                                    ? AnyShapeStyle(LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing))
                                    : AnyShapeStyle(Color(.systemFill))
                            )
                        )
                }
            }
            .buttonStyle(.plain)
            .disabled((!canAfford && !item.isPurchased) || (item.isPurchased && !item.canRepurchase))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
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
                    Stepper("Koszt: \(cost) złota", value: $cost, in: 10...1000, step: 10)
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
