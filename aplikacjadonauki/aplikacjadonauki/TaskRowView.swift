import SwiftUI

struct TaskRowView: View {
    let title: String
    let exp: Int
    let isDone: Bool
    let category: TaskCategory
    let difficulty: TaskDifficulty
    let onToggle: () -> Void

    private var difficultyColor: Color {
        switch difficulty {
        case .easy:   return .green
        case .medium: return .orange
        case .hard:   return .red
        }
    }

    var body: some View {
        HStack(spacing: 10) {

            // Checkbox (obszar dotyku 44x44)
            Button {
                Haptics.tap()
                onToggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(isDone ? Color.green : Color.clear)
                        .frame(width: 28, height: 28)
                    Circle()
                        .strokeBorder(
                            isDone ? Color.green : Color.gray.opacity(0.5),
                            lineWidth: 2
                        )
                        .frame(width: 28, height: 28)
                    if isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .symbolEffect(.bounce, value: isDone)
                    }
                }
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(title)
            .accessibilityValue(isDone ? "Zrobione" : "Do zrobienia")
            .accessibilityHint("Dwukrotnie stuknij, aby zmienić status zadania")

            // Ikona kategorii
            Image(systemName: category.icon)
                .font(.caption)
                .foregroundColor(category.swiftUIColor)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(category.swiftUIColor.opacity(0.15))
                )
                .accessibilityHidden(true)

            // Tytuł + trudność + kategoria
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body)
                    .fontWeight(isDone ? .regular : .semibold)
                    .strikethrough(isDone, color: .secondary)
                    .foregroundStyle(isDone ? AnyShapeStyle(.secondary) : AnyShapeStyle(.primary))
                    .lineLimit(2)
                HStack(spacing: 4) {
                    Text("\(difficulty.icon) \(difficulty.rawValue)")
                        .font(.caption2)
                        .foregroundColor(difficultyColor.opacity(isDone ? 0.6 : 0.95))
                    Text("· \(category.rawValue)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // XP badge
            if !isDone {
                Text("+\(exp) XP")
                    .font(.caption).bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .accessibilityLabel("\(exp) punktów doświadczenia")
            } else {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green.opacity(0.5))
                    .font(.caption)
                    .accessibilityHidden(true)
            }
        }
        .padding(.leading, 6)
        .padding(.trailing, 16)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isDone ? Color.green.opacity(0.07) : Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    isDone ? Color.green.opacity(0.2) : Color.primary.opacity(0.06),
                    lineWidth: 1
                )
        )
        .opacity(isDone ? 0.85 : 1)
        .animation(.easeInOut(duration: 0.2), value: isDone)
    }
}
