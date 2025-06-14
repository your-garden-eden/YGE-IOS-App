import SwiftUI

struct ShimmerView: View {
    
    // ERSETZT: Die hartcodierten .gray-Werte werden durch Farben aus AppColors ersetzt,
    // um einen zum App-Design passenden, dezenten Shimmer-Effekt zu erzielen.
    private let gradient = Gradient(colors: [
        AppColors.backgroundLightGray,
        AppColors.borderLight, // Eine etwas hellere/andere Nuance für den "Glanz"
        AppColors.backgroundLightGray
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

