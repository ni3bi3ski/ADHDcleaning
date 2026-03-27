import SwiftUI

struct TaskRowView: View {
    let title: String
    let exp: Int
    let isDone: Bool
    let category: TaskCategory
    let difficulty: TaskDifficulty
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {

            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(isDone ? Color.green : Color.clear)
                        .frame(width: 28, height: 28)
                    Circle()
                        .strokeBorder(
                            isDone ? Color.green : Color.gray.opacity(0.4),
                            lineWidth: 2
                        )
                        .frame(width: 28, height: 28)
                    if isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            // Ikona kategorii
            Image(systemName: category.icon)
                .font(.caption)
                .foregroundColor(category.swiftUIColor.opacity(0.8))  // FIX: .swiftUIColor

            // Tytuł + trudność
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(isDone ? .regular : .semibold)
                    .strikethrough(isDone, color: .secondary)
                    .foregroundStyle(isDone ? AnyShapeStyle(.tertiary) : AnyShapeStyle(.primary))
                    .lineLimit(2)
                Text("\(difficulty.icon) \(difficulty.rawValue)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
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
            } else {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green.opacity(0.4))
                    .font(.caption)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isDone ? Color.green.opacity(0.05) : Color(.systemBackground))
                .shadow(
                    color: isDone ? .clear : Color.black.opacity(0.06),
                    radius: 6, x: 0, y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    isDone ? Color.green.opacity(0.15) : Color.gray.opacity(0.1),
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isDone)
    }
}
