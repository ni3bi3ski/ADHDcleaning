import SwiftUI

struct ConfettiView: View {
    private struct Piece: Identifiable {
        let id = UUID()
        let x: CGFloat
        let size: CGFloat
        let delay: Double
        let duration: Double
        let color: Color
        let spin: Double
    }

    private static func makePieces() -> [Piece] {
        (0..<60).map { _ in
            Piece(x: CGFloat.random(in: 0...1),
                  size: CGFloat.random(in: 6...12),
                  delay: Double.random(in: 0...0.6),
                  duration: Double.random(in: 1.6...2.8),
                  color: [Color.red, .orange, .yellow, .green, .blue, .purple, .pink].randomElement()!,
                  spin: Double.random(in: 180...720))
        }
    }

    @State private var fall = false
    @State private var pieces: [Piece] = ConfettiView.makePieces()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { p in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(p.color)
                        .frame(width: p.size, height: p.size * 1.6)
                        .rotationEffect(.degrees(fall ? p.spin : 0))
                        .position(x: p.x * geo.size.width,
                                  y: fall ? geo.size.height + 40 : -20)
                        .opacity(fall ? 0.2 : 1)
                        .animation(.easeIn(duration: p.duration).delay(p.delay), value: fall)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { fall = true }
    }
}
