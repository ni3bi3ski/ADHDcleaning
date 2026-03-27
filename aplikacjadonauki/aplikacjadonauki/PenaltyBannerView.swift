import SwiftUI

struct PenaltyBannerView: View {
    let hpLost: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.slash.fill")
                .foregroundColor(.red)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("Kara! 💀")
                    .font(.headline).bold()
                Text("Utracono \(hpLost) HP za niewykonane zadania!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.red.opacity(0.1)))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.red.opacity(0.25), lineWidth: 1)
        )
    }
}
