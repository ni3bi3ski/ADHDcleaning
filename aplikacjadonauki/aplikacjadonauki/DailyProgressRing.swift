import SwiftUI

/// Pierście dzisiejszego postępu: ile zadań dziennych zrobiono z wszystkich.
struct DailyProgressRing: View {
    let done: Int
    let total: Int
    var accent: Color = .blue

    private var progress: Double {
        total == 0 ? 0 : min(1, Double(done) / Double(total))
    }

    private var isComplete: Bool {
        total > 0 && done >= total
    }

    private var subtitle: String {
        if total == 0 { return "Brak zadań dziennych" }
        if isComplete { return "Wszystkie zadania dzienne zrobione" }
        let left = total - done
        let last = left % 10
        let lastTwo = left % 100
        if left == 1 { return "Zostało jedno zadanie" }
        if (2...4).contains(last) && !(12...14).contains(lastTwo) {
            return "Zostały \(left) zadania"
        }
        return "Zostało \(left) zadań"
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(.systemFill), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: isComplete
                                ? [.green, .mint, .green]
                                : [accent.opacity(0.6), accent],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                } else {
                    Text("\(done)/\(total)")
                        .font(.headline.monospacedDigit())
                }
            }
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 4) {
                Text(isComplete ? "Dzień zaliczony! 🎉" : "Dzisiejszy postęp")
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .appCard(tint: accent)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Dzisiejszy postęp")
        .accessibilityValue("\(done) z \(total) zadań dziennych")
    }
}

#Preview {
    VStack(spacing: 16) {
        DailyProgressRing(done: 3, total: 7)
        DailyProgressRing(done: 7, total: 7)
        DailyProgressRing(done: 0, total: 0)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
