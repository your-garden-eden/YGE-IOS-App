//
//  CategoryCarouselItemView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: CategoryCarouselItemView.swift
// PFAD: Features/Home/Views/Components/CategoryCarouselItemView.swift
// ZWECK: Stellt eine einzelne Kategorie als klickbares Element in einem
//        horizontalen Karussell dar.

import SwiftUI

struct CategoryCarouselItemView: View {
    let category: WooCommerceCategory
    let displayName: String
    
    var body: some View {
        VStack(spacing: AppTheme.Layout.Spacing.small) {
            AsyncImage(url: category.image?.src.asURL()) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    ZStack {
                        AppTheme.Colors.backgroundLightGray
                        Image(systemName: "photo.fill")
                            .font(.largeTitle)
                            .foregroundColor(AppTheme.Colors.textMuted.opacity(0.3))
                    }
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .appShadow(AppTheme.Shadows.small)

            Text(displayName)
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.subheadline, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textBase)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 120)
        }
    }
}