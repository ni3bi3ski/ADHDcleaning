import SwiftUI

struct AvatarView: View {
    let equipped: [AvatarLayer: AvatarItem]
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(.systemGray5), Color(.systemGray6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size, height: size)

            // Ciało bazowe
            Image(systemName: equipped[.body]?.symbol ?? "person.fill")
                .font(.system(size: size * 0.55, weight: .medium))
                .foregroundColor(equipped[.body]?.swiftUIColor ?? Color(red: 0.6, green: 0.4, blue: 0.2))
                .offset(y: size * 0.05)

            // Koszulka
            if let shirt = equipped[.shirt] {
                Image(systemName: shirt.symbol)
                    .font(.system(size: size * 0.35, weight: .medium))
                    .foregroundColor(shirt.swiftUIColor)
                    .offset(y: size * 0.18)
            }

            // Spodnie
            if let pants = equipped[.pants] {
                Image(systemName: pants.symbol)
                    .font(.system(size: size * 0.28, weight: .medium))
                    .foregroundColor(pants.swiftUIColor)
                    .offset(y: size * 0.38)
            }

            // Buty
            if let shoes = equipped[.shoes] {
                Image(systemName: shoes.symbol)
                    .font(.system(size: size * 0.22, weight: .medium))
                    .foregroundColor(shoes.swiftUIColor)
                    .offset(y: size * 0.52)
            }

            // Nakrycie głowy
            if let hat = equipped[.hat] {
                Image(systemName: hat.symbol)
                    .font(.system(size: size * 0.30, weight: .medium))
                    .foregroundColor(hat.swiftUIColor)
                    .offset(y: -size * 0.42)
            }

            // Akcesoria
            if let acc = equipped[.accessory] {
                Image(systemName: acc.symbol)
                    .font(.system(size: size * 0.22, weight: .medium))
                    .foregroundColor(acc.swiftUIColor)
                    .offset(x: size * 0.38, y: -size * 0.28)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(Color.white.opacity(0.3), lineWidth: 2))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Avatar Dressing Room
struct AvatarDressingRoomView: View {
    @ObservedObject var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLayer: AvatarLayer = .shirt

    var availableItems: [AvatarItem] {
        AvatarItem.allItems.filter { item in
            vm.shopItems.first(where: { $0.id == item.shopItemId })?.isPurchased == true
                || item.shopItemId == nil
        }
    }

    var itemsForLayer: [AvatarItem] {
        availableItems.filter { $0.layer == selectedLayer }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Podgląd awatara
                ZStack {
                    LinearGradient(
                        colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    AvatarView(equipped: vm.profile.equippedAvatar, size: 160)
                        .padding(30)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)

                // Wybór warstwy
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(AvatarLayer.allCases, id: \.self) { layer in
                            Button {
                                selectedLayer = layer
                            } label: {
                                Text(layer.rawValue)
                                    .font(.caption).bold()
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedLayer == layer
                                                  ? Color.blue
                                                  : Color(.systemFill))
                                    )
                                    .foregroundColor(selectedLayer == layer ? .white : .primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

                Divider()

                // Przedmioty dla wybranej warstwy
                if itemsForLayer.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("Brak przedmiotów")
                            .font(.headline)
                        Text("Kup ubrania w Sklepie aby je tutaj zobaczyć")
                            .font(.subheadline).foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(40)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 12) {
                            // Opcja "zdejmij"
                            Button {
                                vm.unequipAvatar(layer: selectedLayer)
                            } label: {
                                VStack(spacing: 8) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color(.systemFill))
                                            .frame(width: 64, height: 64)
                                        Image(systemName: "xmark.circle")
                                            .font(.system(size: 28))
                                            .foregroundStyle(.secondary)
                                    }
                                    Text("Zdejmij")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)

                            ForEach(itemsForLayer) { item in
                                Button {
                                    vm.equipAvatar(item: item)
                                } label: {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(
                                                    vm.profile.equippedAvatar[item.layer]?.id == item.id
                                                        ? item.swiftUIColor.opacity(0.25)
                                                        : Color(.systemFill)
                                                )
                                                .frame(width: 64, height: 64)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .strokeBorder(
                                                            vm.profile.equippedAvatar[item.layer]?.id == item.id
                                                                ? item.swiftUIColor
                                                                : Color.clear,
                                                            lineWidth: 2
                                                        )
                                                )
                                            Image(systemName: item.symbol)
                                                .font(.system(size: 28))
                                                .foregroundColor(item.swiftUIColor)
                                        }
                                        Text(item.name)
                                            .font(.caption2)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Szatnia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Gotowe") { dismiss() }.bold()
                }
            }
        }
    }
}

// MARK: - Wszystkie przedmioty awatara
extension AvatarItem {
    static let allItems: [AvatarItem] = [
        // Domyślne (zawsze dostępne)
        AvatarItem(name: "Białe ciało",       layer: .body,      symbol: "person.fill",     colorName: "white",  shopItemId: nil),
        AvatarItem(name: "Biała koszulka",    layer: .shirt,     symbol: "tshirt.fill",     colorName: "white",  shopItemId: nil),

        // Do kupienia w sklepie
        AvatarItem(name: "Niebieska bluza",   layer: .shirt,     symbol: "tshirt.fill",     colorName: "blue",   shopItemId: AvatarShopIDs.blueShirt),
        AvatarItem(name: "Czerwona koszulka", layer: .shirt,     symbol: "tshirt.fill",     colorName: "red",    shopItemId: AvatarShopIDs.redShirt),
        AvatarItem(name: "Fioletowa bluza",   layer: .shirt,     symbol: "tshirt.fill",     colorName: "purple", shopItemId: AvatarShopIDs.purpleShirt),
        AvatarItem(name: "Czarne spodnie",    layer: .pants,     symbol: "figure.walk",     colorName: "black",  shopItemId: AvatarShopIDs.blackPants),
        AvatarItem(name: "Niebieskie jeansy", layer: .pants,     symbol: "figure.walk",     colorName: "blue",   shopItemId: AvatarShopIDs.blueJeans),
        AvatarItem(name: "Białe buty",        layer: .shoes,     symbol: "shoeprints.fill", colorName: "white",  shopItemId: AvatarShopIDs.whiteShoes),
        AvatarItem(name: "Czerwone buty",     layer: .shoes,     symbol: "shoeprints.fill", colorName: "red",    shopItemId: AvatarShopIDs.redShoes),
        AvatarItem(name: "Czapka z daszkiem", layer: .hat,       symbol: "baseball.fill",   colorName: "black",  shopItemId: AvatarShopIDs.cap),
        AvatarItem(name: "Korona 👑",          layer: .hat,       symbol: "crown.fill",      colorName: "yellow", shopItemId: AvatarShopIDs.crown),
        AvatarItem(name: "Okulary",           layer: .accessory, symbol: "eyeglasses",      colorName: "black",  shopItemId: AvatarShopIDs.glasses),
        AvatarItem(name: "Trofeum",           layer: .accessory, symbol: "trophy.fill",     colorName: "orange", shopItemId: AvatarShopIDs.sword),
    ]
}

// MARK: - ID przedmiotów sklepowych awatara (alias dla zgodności wstecznej)
typealias AvatarShopItems = AvatarShopIDs
