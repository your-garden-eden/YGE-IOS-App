import SwiftUI

struct ShimmerView: View {
    
    // KORRIGIERT: Verwendet jetzt die zentrale AppTheme-Struktur.
    private let gradient = Gradient(colors: [
        AppTheme.Colors.backgroundLightGray,
        AppTheme.Colors.borderLight.opacity(0.8),
        AppTheme.Colors.backgroundLightGray
    ])
    
    @State private var startPoint: UnitPoint = .init(x: -1.8, y: -1.2)
    @State private var endPoint: UnitPoint = .init(x: 0, y: -0.2)
    
    var body: some View {
        LinearGradient(
            gradient: gradient,
            startPoint: startPoint,
            endPoint: endPoint
        )
        .onAppear {
            withAnimation(
                .linear(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                startPoint = .init(x: 1, y: 1)
                endPoint = .init(x: 2.8, y: 2.2)
            }
        }
    }
}
