import SwiftUI



// MARK: - Level Up Banner
struct LevelUpBannerView: View {
    let level: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow).font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("LEVEL UP! 🎉").font(.headline).bold()
                Text("Osiągnąłeś poziom \(level)!")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Text("Lvl \(level)")
                .font(.title2).bold()
                .foregroundStyle(
                    LinearGradient(colors: [.yellow, .orange],
                                   startPoint: .leading, endPoint: .trailing)
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.yellow.opacity(0.12))
        )
        .overlay(RoundedRectangle(cornerRadius: 14)
            .strokeBorder(Color.yellow.opacity(0.35), lineWidth: 1.5))
        .padding(.horizontal)
    }
}
