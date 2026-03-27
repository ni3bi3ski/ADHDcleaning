import SwiftUI

struct AchievementBannerView: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [achievement.swiftUIColor, achievement.swiftUIColor.opacity(0.6)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 44, height: 44)
                Image(systemName: achievement.icon)
                    .font(.body).bold()
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Nowe osiągnięcie! 🎉")
                    .font(.caption).bold()
                    .foregroundColor(.white.opacity(0.85))
                Text(achievement.title)
                    .font(.headline).bold()
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [achievement.swiftUIColor, achievement.swiftUIColor.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: achievement.swiftUIColor.opacity(0.4), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct ChallengeCompletedBannerView: View {
    var body: some View {
        HStack(spacing: 12) {
            Text("⚡")
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("Wyzwanie ukończone!")
                    .font(.headline).bold()
                    .foregroundColor(.white)
                Text("Świetna robota! Wyzwanie tygodnia zaliczone.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [.teal, .blue],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .teal.opacity(0.4), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}
