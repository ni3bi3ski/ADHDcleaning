import SwiftUI

/// Wspólny styl kart w całej aplikacji.
extension View {
    func appCard(tint: Color? = nil) -> some View {
        self
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder((tint ?? Color.primary).opacity(tint == nil ? 0.06 : 0.28), lineWidth: 1)
            )
    }
}
