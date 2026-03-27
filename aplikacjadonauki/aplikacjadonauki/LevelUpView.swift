import SwiftUI

struct LevelUpView: View {
    let newLevel: Int
    let bonusXP: Int
    let unlockedTasks: [CleaningTask]
    let onClaim: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var isMasterLevel: Bool { newLevel >= 11 }

    var body: some View {
        ZStack {
            // Tło — złote dla Mistrza, czarne normalnie
            if isMasterLevel {
                LinearGradient(
                    colors: [Color.black, Color(red: 0.4, green: 0.3, blue: 0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                Color.black.opacity(0.85)
                    .ignoresSafeArea()
            }

            VStack(spacing: 28) {
                Spacer()

                // Animowany nagłówek
                VStack(spacing: 8) {
                    Text(isMasterLevel ? "🏆" : "🎉")
                        .font(.system(size: 72))

                    if isMasterLevel {
                        Text("MISTRZ CZYSTOŚCI!")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)

                        Text("Ukończyłeś wszystkie zadania!")
                            .font(.title3).bold()
                            .foregroundColor(.white.opacity(0.9))

                        Text("Poziom 11 — Finalny!")
                            .font(.subheadline)
                            .foregroundColor(.yellow.opacity(0.7))
                    } else {
                        Text("POZIOM \(newLevel)!")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("Awansowałeś!")
                            .font(.title2).bold()
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .scaleEffect(scale)
                .opacity(opacity)

                // Bonus XP
                HStack(spacing: 12) {
                    Image(systemName: isMasterLevel ? "trophy.fill" : "bolt.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                    Text(isMasterLevel ? "Wszystkie zadania ukończone!" : "+\(bonusXP) Bonus XP")
                        .font(.title3).bold()
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 1.5)
                )

                // Odblokowane zadania (tylko dla normalnych levelów)
                if !unlockedTasks.isEmpty && !isMasterLevel {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🔓 Nowe zadania odblokowane:")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))

                        ForEach(unlockedTasks.prefix(4)) { task in
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                Text(task.title)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("+\(task.exp) XP")
                                    .font(.caption).bold()
                                    .foregroundColor(.blue.opacity(0.8))
                            }
                        }

                        if unlockedTasks.count > 4 {
                            Text("...i \(unlockedTasks.count - 4) więcej")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }

                // Specjalna sekcja dla Mistrza – POPRAWIONE StatPill
                if isMasterLevel {
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            StatPill(
                                icon: "checkmark.seal.fill",
                                color: .green,
                                label: "Zadań",
                                value: "60"
                            )
                            StatPill(
                                icon: "bolt.fill",
                                color: .yellow,
                                label: "XP",
                                value: "841"
                            )
                            StatPill(
                                icon: "flame.fill",
                                color: .orange,
                                label: "Status",
                                value: "Legenda"
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Przycisk
                Button(action: onClaim) {
                    Text(isMasterLevel ? "🏆 Odbierz tytuł Mistrza!" : "Odbierz nagrodę!")
                        .font(.headline).bold()
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: isMasterLevel
                                    ? [.yellow, .orange, .red]
                                    : [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
