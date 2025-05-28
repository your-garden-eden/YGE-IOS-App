// YGE-IOS-App/Features/Home/Views/HomeView.swift

import SwiftUI

struct HomeView: View {
    // @StateObject var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    heroImageView()
                        .frame(height: 280)
                        .padding(.bottom, AppStyles.Spacing.large)

                    featuredProductsSection()
                        .padding(.bottom, AppStyles.Spacing.large)
                    
                    Spacer()
                }
            }
            .background(AppColors.backgroundPage.ignoresSafeArea())
            .navigationTitle("Startseite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundComponent.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("logo_your_garden_eden_transparent")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: AppStyles.Spacing.small) {
                        Button {} label: { Image(systemName: "magnifyingglass").font(.title3).foregroundColor(AppColors.textHeadings) }
                        Button {} label: { Image(systemName: "heart").font(.title3).foregroundColor(AppColors.textHeadings) }
                        Button {} label: { Image(systemName: "cart").font(.title3).foregroundColor(AppColors.textHeadings) }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func heroImageView() -> some View {
        ZStack(alignment: .bottomLeading) {
            Image("hero_main_banner_yge")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 280)
                .clipped()

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.5), Color.black.opacity(0)]),
                startPoint: .bottom,
                endPoint: .center
            )

            Text("Your-Garden-Eden")
                .font(AppFonts.montserrat(size: AppFonts.Size.h1, weight: .bold))
                .foregroundColor(AppColors.textOnPrimary)
                .padding(AppStyles.Spacing.large)
                .shadow(color: AppColors.secondary.opacity(0.7), radius: 3, x: 1, y: 1)
        }
    }

    @ViewBuilder
    private func featuredProductsSection() -> some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
            Text("Unsere Bestseller")
                .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
                .padding(.horizontal, AppStyles.Spacing.medium)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppStyles.Spacing.medium) {
                    ForEach(0..<5) { _ in
                        ProductCardViewPlaceholder()
                    }
                }
                .padding(.horizontal, AppStyles.Spacing.medium)
                .padding(.vertical, AppStyles.Spacing.small)
            }
        }
    }
}

struct ProductCardViewPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
            ZStack {
                RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium)
                    .fill(AppColors.backgroundComponent)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium)
                            .stroke(AppColors.borderLight, lineWidth: 1)
                    )
                
                Image("product_placeholder_sonnenliege")
                    .resizable()
                    .scaledToFit()
                    .padding(AppStyles.Spacing.small)
            }
            
            Text("Klappliege mit Sonnenschutz")
                .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .medium))
                .foregroundColor(AppColors.textBase)
                .lineLimit(2)
                .frame(height: 40, alignment: .top)

            Text("In mehreren Varianten")
                // KORREKTUR HIER: .normal zu .regular
                .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .regular))
                .foregroundColor(AppColors.textMuted)
            
            Spacer()
        }
        .frame(width: 160)
        .padding(AppStyles.Spacing.small)
        .background(AppColors.backgroundComponent)
        .cornerRadius(AppStyles.BorderRadius.large)
        // KORREKTUR HIER: AppStyles.Shadows.small direkt übergeben
        .appShadow(AppStyles.Shadows.small)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
