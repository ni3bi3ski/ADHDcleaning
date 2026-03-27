import SwiftUI

// MARK: - HeaderCardView
struct HeaderCardView: View {
    let level: Int
    let streak: Int
    let experience: Int
    let levelProgress: Double
    let xpForNextLevel: Int
    let onShowStats: () -> Void

    var isMasterLevel: Bool { level >= 10 }

    @State private var animatedProgress: Double = 0
    @State private var glowPulse: Bool = false

    private var cardColors: [Color] {
        isMasterLevel
            ? [Color(red: 0.55, green: 0.35, blue: 0.0), Color(red: 0.8, green: 0.55, blue: 0.0)]
            : levelGradient
    }

    private var levelGradient: [Color] {
        switch level {
        case 1...2: return [Color(red: 0.18, green: 0.48, blue: 0.90), Color(red: 0.10, green: 0.72, blue: 0.85)]
        case 3...4: return [Color(red: 0.30, green: 0.70, blue: 0.40), Color(red: 0.10, green: 0.85, blue: 0.65)]
        case 5...6: return [Color(red: 0.60, green: 0.20, blue: 0.90), Color(red: 0.30, green: 0.50, blue: 1.00)]
        case 7...8: return [Color(red: 0.90, green: 0.35, blue: 0.20), Color(red: 1.00, green: 0.65, blue: 0.10)]
        case 9:     return [Color(red: 0.85, green: 0.10, blue: 0.50), Color(red: 0.95, green: 0.40, blue: 0.10)]
        default:    return [.yellow, .orange]
        }
    }

    private var xpRemaining: Int {
        isMasterLevel ? 0 : max(0, xpForNextLevel - (experience % max(xpForNextLevel, 1)))
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // — Gradient tło
            RoundedRectangle(cornerRadius: 28)
                .fill(LinearGradient(colors: cardColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(maxWidth: .infinity)

            // — Dekoracyjne kółka w tle
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 160, height: 160)
                    .offset(x: geo.size.width - 80, y: -60)
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 100, height: 100)
                    .offset(x: geo.size.width - 50, y: 30)
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 70, height: 70)
                    .offset(x: 20, y: 90)
            }
            .clipped()

            // — Treść
            VStack(alignment: .leading, spacing: 16) {
                // Górny wiersz: level badge + XP + stats
                HStack(alignment: .top) {
                    // Level badge
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 48, height: 48)
                                if isMasterLevel {
                                    Text("🏆").font(.title2)
                                } else {
                                    Text("\(level)")
                                        .font(.system(size: 22, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(isMasterLevel ? "Mistrz Czystości" : "Poziom \(level)")
                                    .font(.title3).bold()
                                    .foregroundColor(.white)
                                Text(isMasterLevel
                                     ? "Poziom MAX — Legenda!"
                                     : "Jeszcze \(xpRemaining) XP do awansu")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.75))
                            }
                        }
                    }

                    Spacer()

                    // XP pill + stats button
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.caption).bold()
                                .foregroundColor(.white.opacity(0.85))
                            Text("\(experience) XP")
                                .font(.subheadline).bold()
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                        Button(action: onShowStats) {
                            HStack(spacing: 4) {
                                Image(systemName: "chart.bar.fill")
                                Text("Statystyki")
                            }
                            .font(.caption).bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Streak row
                HStack(spacing: 8) {
                    Text("🔥")
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Seria \(streak) \(streak == 1 ? "dzień" : "dni") z rzędu")
                            .font(.subheadline).bold()
                            .foregroundColor(.white)
                        if streak >= 7 {
                            Text("Absolutny ogień! Tak trzymaj 💪")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.75))
                        } else if streak >= 3 {
                            Text("Budujesz momentum!")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.75))
                        } else if streak == 0 {
                            Text("Zacznij dzisiaj — pierwszy krok!")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.75))
                        }
                    }
                    Spacer()
                    if streak >= 7 {
                        Text("🔥 W ogniu!")
                            .font(.caption).bold()
                            .foregroundColor(.orange)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Color.white.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // XP Progress bar
                VStack(spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            // Track
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.20))
                                .frame(height: 10)
                            // Fill
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    colors: [.white.opacity(0.95), .white.opacity(0.65)],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                                .frame(width: geo.size.width * animatedProgress, height: 10)
                                .animation(.spring(response: 0.7, dampingFraction: 0.75), value: animatedProgress)
                            // Shine
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    colors: [.white.opacity(0.5), .clear],
                                    startPoint: .top, endPoint: .bottom
                                ))
                                .frame(width: geo.size.width * animatedProgress, height: 5)
                                .animation(.spring(response: 0.7, dampingFraction: 0.75), value: animatedProgress)
                        }
                    }
                    .frame(height: 10)

                    HStack {
                        Text(isMasterLevel ? "Poziom MAX 🎉" : "Postęp do poziomu \(level + 1)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.70))
                        Spacer()
                        Text(isMasterLevel ? "100%" : "\(Int(levelProgress * 100))%")
                            .font(.caption2).bold()
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: cardColors[0].opacity(0.45), radius: 20, x: 0, y: 8)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.2)) {
                animatedProgress = isMasterLevel ? 1.0 : levelProgress
            }
        }
        .onChange(of: levelProgress) { val in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                animatedProgress = isMasterLevel ? 1.0 : val
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HeaderCardView(level: 3, streak: 5, experience: 350, levelProgress: 0.60, xpForNextLevel: 300, onShowStats: {})
        HeaderCardView(level: 10, streak: 14, experience: 1500, levelProgress: 1.0, xpForNextLevel: 0, onShowStats: {})
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
