import SwiftUI

struct ProductCategoryRow: View {
    let category: WooCommerceCategory

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageInfo = category.image, let url = imageInfo.src.asURL() {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        placeholderImage()
                    } else {
                        placeholderProgressView()
                    }
                }
            } else {
                placeholderImage()
            }

            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.1), .black.opacity(0.7)]),
                startPoint: .center,
                endPoint: .bottom
            )

            Text(category.name)
                .font(AppFonts.montserrat(size: 22, weight: .bold)) // Angepasster Font für bessere Sichtbarkeit
                .foregroundColor(.white)
                .padding()
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2) // Textschatten für Kontrast
        }
        .frame(height: 150)
        .background(AppColors.backgroundLightGray)
        .cornerRadius(AppStyles.BorderRadius.medium)
        .clipped()
    }

    @ViewBuilder
    private func placeholderImage() -> some View {
        ZStack {
            AppColors.backgroundLightGray
            Image(systemName: "photo.on.rectangle.angled")
                .resizable()
                .scaledToFit()
                .foregroundColor(AppColors.textMuted.opacity(0.5))
                .padding(30)
        }
    }
    
    @ViewBuilder
    private func placeholderProgressView() -> some View {
        ZStack {
            AppColors.backgroundLightGray
            ProgressView()
        }
    }
}
