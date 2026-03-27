import SwiftUI

struct WeeklyResetBannerView: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("🔄")
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("Nowy tydzień!")
                    .font(.headline).bold()
                    .foregroundColor(.white)
                Text("Zadania zresetowane — czas na nowe XP!")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
    }
}
