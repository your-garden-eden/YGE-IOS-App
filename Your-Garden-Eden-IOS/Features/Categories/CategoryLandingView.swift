// DATEI: CategoryLandingView.swift
// PFAD: Features/Categories/Views/CategoryLandingView.swift
// VERSION: 6.2 (FINAL)

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
            AppTheme.Colors.backgroundPage.ignoresSafeArea()
            
            switch viewModel.viewState {
            case .loading: ProgressView().tint(AppTheme.Colors.primary)
            case .showSubCategories: subCategoryListView
            case .showProducts: ProductListView(category: category)
            case .empty: emptyStateView
            case .error(let message): StatusIndicatorView.errorState(message: message)
            }
        }
        .navigationTitle(getDisplayName(for: category))
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton()
        .task { await viewModel.loadContent() }
    }
    
    private var subCategoryListView: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Layout.Spacing.large) {
                ForEach(viewModel.subCategories) { subCategory in
                    NavigationLink(value: subCategory) {
                        CategoryCardView(
                            category: subCategory,
                            style: .bannerWithTextOverlay(displayName: getDisplayName(for: subCategory))
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Layout.Spacing.large) {
            Image(systemName: "tray.fill").font(.system(size: 60)).foregroundColor(AppTheme.Colors.primary.opacity(0.5))
            Text("Keine Produkte").font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.title2, weight: .bold))
            Text("In dieser Kategorie wurden leider keine Produkte gefunden.").font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body)).foregroundColor(AppTheme.Colors.textMuted).multilineTextAlignment(.center)
        }.padding()
    }
    
    private func getDisplayName(for category: WooCommerceCategory) -> String {
        if let mainItem = NavigationData.items.first(where: { $0.mainCategorySlug == category.slug }) {
            return mainItem.label
        }
        for item in NavigationData.items {
            if let subItems = item.subItems, let subItem = subItems.first(where: { $0.linkSlug == category.slug }) {
                return subItem.label
            }
        }
        return category.name.strippingHTML()
    }
}
