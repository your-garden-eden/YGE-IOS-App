import SwiftUI

struct ProductCardView: View {
    @StateObject private var viewModel: ProductCardViewModel
    @EnvironmentObject var wishlistState: WishlistState

    init(product: WooCommerceProduct) {
        _viewModel = StateObject(wrappedValue: ProductCardViewModel(product: product))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
            // MARK: - Bild
            // --- KORREKTUR: Hier ist der vollständige und korrekte Code für den AsyncImage-Block ---
            AsyncImage(url: viewModel.imageURL) { phase in // Der 'phase'-Parameter wird jetzt korrekt angenommen
                switch phase {
                case .empty:
                    ZStack {
                        AppColors.backgroundLightGray
                        ProgressView().tint(AppColors.primary)
                    }
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fit)
                case .failure:
                    ZStack {
                        AppColors.backgroundLightGray
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(AppColors.textMuted.opacity(0.6))
                            .padding()
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 150)
            .cornerRadius(AppStyles.BorderRadius.medium)
            .clipped()

            // MARK: - Produktname
            Text(viewModel.displayName)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppColors.textHeadings)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            // MARK: - Preis und Herz-Button
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.displayPrice)
                        .font(.callout.weight(.bold))
                        .foregroundColor(AppColors.price)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    if let strikethrough = viewModel.strikethroughPrice {
                        Text(strikethrough)
                            .font(.caption)
                            .foregroundColor(AppColors.textMuted)
                            .strikethrough(true, color: AppColors.textMuted)
                    }
                }
                
                Spacer()

                Button {
                    wishlistState.toggleWishlistStatus(for: viewModel.productId)
                } label: {
                    Image(systemName: wishlistState.isProductInWishlist(productId: viewModel.productId) ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(wishlistState.isProductInWishlist(productId: viewModel.productId) ? AppColors.wishlistIcon : AppColors.textMuted)
                }
            }
        }
        .padding(AppStyles.Spacing.small)
        .background(AppColors.backgroundComponent)
        .cornerRadius(AppStyles.BorderRadius.large)
        .appShadow(AppStyles.Shadows.small)
        .task {
            await viewModel.calculatePrices()
        }
    }
}
