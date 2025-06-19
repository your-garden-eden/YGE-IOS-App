// DATEI: ProductCategoryRowView.swift
// PFAD: Features/Products/Views/Components/ProductCategoryRowView.swift
// ZWECK: (UNVERÄNDERT & GEPRÜFT)

import SwiftUI

struct ProductCategoryRowView: View {
    let label: String
    let imageUrl: URL?
    let localImageFilename: String?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            imageBanner
                .frame(height: 120)
                .cornerRadius(AppTheme.Layout.BorderRadius.large)
                .clipped()

            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )
            .cornerRadius(AppTheme.Layout.BorderRadius.large)

            Text(label)
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.title2, weight: .bold))
                .foregroundColor(.white)
                .padding()
        }
        .appShadow(AppTheme.Shadows.medium)
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
                case .failure, .empty:
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
            AppTheme.Colors.backgroundLightGray
            Image(systemName: "photo.fill")
                .font(.largeTitle)
                .foregroundColor(AppTheme.Colors.textMuted.opacity(0.3))
        }
    }
}
