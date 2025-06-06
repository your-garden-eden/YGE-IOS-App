import SwiftUI

struct ProductCategoryRow: View {
    let category: WooCommerceCategory

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // AsyncImage lädt das Bild
            AsyncImage(url: category.image?.src.asURL()) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderImage()
                case .empty:
                    ShimmerView()
                @unknown default:
                    EmptyView()
                }
            }

            // Gradient für die Lesbarkeit
            LinearGradient(
                gradient: Gradient(colors: [.clear, AppColors.secondaryDark.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )

            // Kategoriename
            Text(category.name)
                // UPDATED: Nutzt den "title2" Stil. Dieser ist prominent und passt gut auf Bild-Header.
                .font(.title2.weight(.bold))
                .foregroundColor(AppColors.textOnSecondary)
                .padding()
                .shadow(color: AppColors.secondaryDark.opacity(0.5), radius: 3, x: 0, y: 2)
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
}
