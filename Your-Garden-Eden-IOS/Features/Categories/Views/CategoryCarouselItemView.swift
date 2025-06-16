// Path: Your-Garden-Eden-IOS/Features/Categories/Views/CategoryCarouselItemView.swift
// VERSION 2.4 (FINAL): Adjusted font size for the category headline.

import SwiftUI

struct CategoryCarouselItemView: View {
    let category: WooCommerceCategory
    let displayName: String
    
    var body: some View {
        VStack(spacing: AppStyles.Spacing.small) {
            
            ZStack {
                imageBanner
            }
            .frame(width: 160, height: 110)
            .cornerRadius(AppStyles.BorderRadius.large)
            .clipped()
            .appShadow(AppStyles.Shadows.medium)

            // FIX: Schriftgröße angepasst für bessere Lesbarkeit und Hierarchie.
            Text(displayName)
                .font(AppFonts.montserrat(size: AppFonts.Size.subheadline, weight: .semibold))
                .foregroundColor(AppColors.textBase)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 150, height: 40, alignment: .top)
        }
    }
    
    @ViewBuilder
    private var imageBanner: some View {
        switch category.slug {
            // --- Hauptkategorien ---
        case "gartenmoebel": Image("cat_banner_gartenmoebel").resizable().aspectRatio(contentMode: .fill)
        case "sonnenschutz": Image("cat_banner_sonnenschutz").resizable().aspectRatio(contentMode: .fill)
        case "wasser-im-garten": Image("cat_banner_wasser_im_garten").resizable().aspectRatio(contentMode: .fill)
        case "heizen-feuer": Image("cat_banner_heizen_feuer").resizable().aspectRatio(contentMode: .fill)
        case "gartenhelfer-aufbewahrung": Image("cat_banner_gartenhelfer").resizable().aspectRatio(contentMode: .fill)
        case "deko-licht": Image("cat_banner_deko_licht").resizable().aspectRatio(contentMode: .fill)
        case "pflanzen-anzucht": Image("cat_banner_pflanzen_anzucht").resizable().aspectRatio(contentMode: .fill)
        case "fuer-die-ganze-grossen": Image("cat_banner_spiel_spass").resizable().aspectRatio(contentMode: .fill)
        case "grills-outdoor-kuechen": Image("cat_banner_grills_outdoor_kuechen").resizable().aspectRatio(contentMode: .fill)
            
        default:
            if let apiImageURL = category.image?.src.asURL() {
                AsyncImage(url: apiImageURL) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
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
