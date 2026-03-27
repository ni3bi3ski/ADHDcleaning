import SwiftUI
import AudioToolbox

// MARK: - HapticManager
class HapticManager {
    enum Style { case medium, light, rigid, soft, heavy }

    static func impact(_ style: Style) {
        let generator: UIImpactFeedbackGenerator
        switch style {
        case .medium: generator = UIImpactFeedbackGenerator(style: .medium)
        case .light:  generator = UIImpactFeedbackGenerator(style: .light)
        case .rigid:  generator = UIImpactFeedbackGenerator(style: .rigid)
        case .soft:   generator = UIImpactFeedbackGenerator(style: .soft)
        case .heavy:  generator = UIImpactFeedbackGenerator(style: .heavy)
        }
        generator.impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func notification(_ success: Bool) {
        UINotificationFeedbackGenerator()
            .notificationOccurred(success ? .success : .error)
    }
}

// MARK: - SoundManager
class SoundManager {
    static let shared = SoundManager()
    private init() {}

    func playCoin()   { AudioServicesPlaySystemSound(1057) }
    func playTick()   { AudioServicesPlaySystemSound(1104) }
    func playMagic()  { AudioServicesPlaySystemSound(1025) }
    func playWhoosh() { AudioServicesPlaySystemSound(1026) }
}

// MARK: - BoostBadgeView
struct BoostBadgeView: View {
    let key: String
    let expiry: Date

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .font(.caption2)
                .foregroundColor(.orange)
            Text(key)
                .font(.caption2).bold()
                .foregroundColor(.orange)
            Text(timeLeft)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(Capsule().fill(Color.orange.opacity(0.10)))
        .overlay(Capsule().strokeBorder(Color.orange.opacity(0.25), lineWidth: 1))
    }

    private var timeLeft: String {
        let diff = expiry.timeIntervalSinceNow
        guard diff > 0 else { return "wygasł" }
        let h = Int(diff) / 3600
        let m = (Int(diff) % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }
}

// MARK: - HPBarView
struct HPBarView: View {
    let hp: Int
    private let maxHP = 100

    private var color: Color {
        switch hp {
        case 66...: return .green
        case 33...: return .orange
        default:    return .red
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemFill))
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(min(hp, maxHP)) / CGFloat(maxHP))
                    .animation(.spring(response: 0.4), value: hp)
            }
        }
    }
}
