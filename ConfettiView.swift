import SwiftUI
import SwiftData

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                ConfettiPieceView(piece: piece)
            }
        }
        .onAppear {
            generateConfetti()
        }
    }
    
    private func generateConfetti() {
        let colors: [Color] = [
            Color(hex: "FF6B6B"),
            Color(hex: "4ECDC4"),
            Color(hex: "FFD700"),
            Color(hex: "96E6B3"),
            Color(hex: "FF8787"),
            Color(hex: "45B7D1")
        ]
        
        let shapes: [String] = ["circle", "square", "triangle", "star"]
        
        for _ in 0..<100 {
            let piece = ConfettiPiece(
                id: UUID(),
                color: colors.randomElement()!,
                shape: shapes.randomElement()!,
                startX: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                startY: -50,
                size: CGFloat.random(in: 8...20),
                rotation: Double.random(in: 0...360),
                duration: Double.random(in: 2...4)
            )
            confettiPieces.append(piece)
        }
    }
}
