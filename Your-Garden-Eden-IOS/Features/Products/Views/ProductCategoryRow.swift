import SwiftUI

struct ProductCategoryRow: View {
    let label: String
    let imageUrl: URL?
    let localImageFilename: String?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            imageBanner
                .frame(height: 120)
                .cornerRadius(AppStyles.BorderRadius.large)
                .clipped()

            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(AppStyles.BorderRadius.large)

            Text(label)
                .font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .bold))
                .foregroundColor(.white)
                .padding()
        }
        .appShadow(AppStyles.Shadows.medium)
    }

    @ViewBuilder
    private var imageBanner: some View {
        if let filename = localImageFilename {
            Image(filename)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        else if let url = imageUrl {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderView
                case .empty:
                    placeholderView
                @unknown default:
                    EmptyView()
                }
            }
        }
        else {
            placeholderView
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            AppColors.backgroundLightGray
            Image(systemName: "photo.fill")
                .font(.largeTitle)
                .foregroundColor(AppColors.textMuted.opacity(0.3))
        }
    }
}
