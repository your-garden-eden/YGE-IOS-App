import SwiftUI

struct ProductCategoryRow: View {
    let label: String
    let imageUrl: URL?
    let localImageFilename: String?

    var body: some View {
        // GEÄNDERT: Die Ausrichtung des ZStacks ist jetzt .center.
        ZStack(alignment: .center) {
            // Das Bild bleibt die unterste Ebene.
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                
                case .failure, .empty:
                    if let filename = localImageFilename {
                        Image(filename)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        placeholderImage()
                    }
                @unknown default:
                    EmptyView()
                }
            }

            // GEÄNDERT: Wir verwenden jetzt einen durchgehenden, leichten
            // dunklen Schleier über dem ganzen Bild für bessere Lesbarkeit.
            Rectangle()
                .fill(.black.opacity(0.40))

            // GEÄNDERT: Die Textfarbe ist jetzt .white.
            Text(label)
                .font(.title2.weight(.bold))
                .foregroundColor(.white) // Textfarbe ist weiß
                .padding()
                // Der Schatten sorgt für zusätzlichen Kontrast.
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
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
