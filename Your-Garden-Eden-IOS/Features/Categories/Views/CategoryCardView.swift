// DATEI: CategoryCardView.swift
// PFAD: Features/Categories/Views/Components/CategoryCardView.swift
// VERSION: 1.1 (FINAL & KORREKT)

import SwiftUI

struct CategoryCardView: View {
    
    enum DisplayStyle {
        case bannerWithTextOverlay(displayName: String)
        case imageOnly
    }
    
    let category: WooCommerceCategory
    let style: DisplayStyle

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            imageProvider
                .frame(maxWidth: .infinity)
                .aspectRatio(16/9, contentMode: .fill)
                .background(AppTheme.Colors.backgroundLightGray)
                .clipped()
            
            if case .bannerWithTextOverlay(let displayName) = style {
                textOverlay(with: displayName)
            }
        }
        .cornerRadius(AppTheme.Layout.BorderRadius.large)
        .appShadow(AppTheme.Shadows.medium)
    }
    
    @ViewBuilder
    private var imageProvider: some View {
        // Dieser Aufruf ist korrekt und wartet auf die Auflösung des externen Konflikts.
        if let image = ImageProvider.banner(forCategorySlug: category.slug) {
            image
                .resizable()
        } else if let url = category.image?.src.asURL() {
            AsyncImage(url: url) { phase in
                if let image = phase.image { image.resizable() } else { placeholderView }
            }
        } else {
            placeholderView
        }
    }
    
    private var placeholderView: some View {
        Image(systemName: "photo.fill")
            .font(.largeTitle)
            .foregroundColor(AppTheme.Colors.textMuted.opacity(0.3))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func textOverlay(with text: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .center, endPoint: .bottom)
            Text(text)
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.title2, weight: .bold))
                .foregroundColor(.white)
                .padding()
        }
    }
}
