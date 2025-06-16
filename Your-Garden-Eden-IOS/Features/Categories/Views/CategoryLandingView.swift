// Path: Your-Garden-Eden-IOS/Features/Categories/Views/CategoryLandingView.swift
// VERSION 5.0 (FINAL & PERFECTED): Implements individual headlines for each sub-category card.

import SwiftUI

struct CategoryLandingView: View {
    
    @StateObject private var viewModel: CategoryLandingViewModel
    private let category: WooCommerceCategory

    init(category: WooCommerceCategory) {
        self.category = category
        _viewModel = StateObject(wrappedValue: CategoryLandingViewModel(category: category))
    }

    var body: some View {
        ZStack {
            AppColors.backgroundPage.ignoresSafeArea()
            
            switch viewModel.viewState {
            case .loading:
                ProgressView().tint(AppColors.primary)
            
            case .showSubCategories:
                // FIX: Die Logik wurde komplett neu aufgebaut, um individuelle Überschriften zu ermöglichen.
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: AppStyles.Spacing.large) {
                        ForEach(viewModel.subCategories) { subCategory in
                            VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
                                // 1. Individuelle Überschrift für jede Unterkategorie
                                Text(Self.findLabelFor(category: subCategory))
                                    .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .bold))
                                    .foregroundColor(AppColors.textHeadings)
                                
                                // 2. Die zugehörige klickbare Karte
                                NavigationLink(value: subCategory) {
                                    ShopCategoryCardView(
                                        category: subCategory,
                                        displayName: Self.findLabelFor(category: subCategory)
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                }
                
            case .showProducts:
                ProductListView(category: category)

            case .empty:
                emptyProductsView
                
            case .error(let message):
                ErrorStateView(message: message)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo_your_garden_eden_transparent")
                    .resizable().scaledToFit().frame(height: 150)
            }
        }
        .task {
            await viewModel.loadContent()
        }
    }
    
    private var emptyProductsView: some View {
        VStack(spacing: AppStyles.Spacing.large) {
            Image(systemName: "tray.fill").font(.system(size: 60)).foregroundColor(AppColors.primary.opacity(0.5))
            Text("Keine Produkte").font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .bold)).foregroundColor(AppColors.textHeadings)
            Text("In dieser Kategorie wurden leider keine Produkte gefunden.").font(AppFonts.roboto(size: AppFonts.Size.body)).foregroundColor(AppColors.textMuted).multilineTextAlignment(.center)
        }.padding()
    }
    
    private static func findLabelFor(category: WooCommerceCategory) -> String {
        if let mainItem = AppNavigationData.items.first(where: { $0.mainCategorySlug == category.slug }) {
            return mainItem.label
        }
        for item in AppNavigationData.items {
            if let subItems = item.subItems, let subItem = subItems.first(where: { $0.linkSlug == category.slug }) {
                return subItem.label
            }
        }
        return category.name.strippingHTML()
    }
}
