import SwiftUI

// MARK: - QuickStartCardView
struct QuickStartCardView: View {
    let taskTitle: String
    let onDone: () -> Void

    @State private var pressed: Bool    = false
    @State private var completed: Bool  = false
    @State private var checkScale: CGFloat = 0.5

    var body: some View {
        HStack(spacing: 16) {
            // ✅ Lewa ikona — animowana
            ZStack {
                Circle()
                    .fill(completed
                          ? LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [Color(red: 1.0, green: 0.7, blue: 0.0), Color(red: 1.0, green: 0.45, blue: 0.0)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52)
                    .shadow(color: completed ? Color.green.opacity(0.35) : Color.orange.opacity(0.35), radius: 8, x: 0, y: 3)
                Image(systemName: completed ? "checkmark" : "bolt.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(completed ? checkScale : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.55), value: checkScale)
            }

            // Środek — tytuł + label
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Text("Szybki start")
                        .font(.caption).bold()
                        .foregroundStyle(.secondary)
                    Image(systemName: "shuffle")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                Text(taskTitle)
                    .font(.headline)
                    .foregroundColor(completed ? .secondary : .primary)
                    .lineLimit(2)
                    .strikethrough(completed, color: .secondary)
                    .animation(.easeInOut(duration: 0.2), value: completed)
            }

            Spacer()

            // Przycisk / stan ukończenia
            if completed {
                VStack(spacing: 2) {
                    Text("✓").font(.title3).bold().foregroundColor(.green)
                    Text("Zrobione").font(.caption2).bold().foregroundColor(.green)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) { pressed = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                            pressed = false
                            completed = true
                            checkScale = 1.0
                        }
                        onDone()
                    }
                } label: {
                    Text("Zrobione!")
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 18).padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing))
                        )
                        .shadow(color: Color.green.opacity(0.35), radius: 8, x: 0, y: 3)
                }
                .buttonStyle(.plain)
                .scaleEffect(pressed ? 0.93 : 1.0)
                .animation(.spring(response: 0.28, dampingFraction: 0.6), value: pressed)
            }
        }
        .padding(.horizontal, 18).padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
                .shadow(color: completed ? Color.green.opacity(0.18) : Color.black.opacity(0.07), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(
                    LinearGradient(
                        colors: completed
                            ? [.green.opacity(0.55), .teal.opacity(0.25)]
                            : [.orange.opacity(0.30), .yellow.opacity(0.15)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ), lineWidth: 1.2
                )
        )
        .animation(.easeInOut(duration: 0.25), value: completed)
        .onAppear { checkScale = 0.5 }
    }
}

#Preview {
    VStack(spacing: 12) {
        QuickStartCardView(taskTitle: "Pościel łóżko i wietrz pokój", onDone: {})
        QuickStartCardView(taskTitle: "Wynieś śmieci", onDone: {})
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
