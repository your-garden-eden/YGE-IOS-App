// DATEI: ShopView.swift
// PFAD: Features/Categories/Views/ShopView.swift
// VERSION: 1.1 (FINAL)

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundPage.ignoresSafeArea()

            if viewModel.isLoadingCategories {
                ProgressView().tint(AppTheme.Colors.primary)
            } else if let errorMessage = viewModel.categoryErrorMessage {
                StatusIndicatorView.errorState(message: errorMessage)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.large) {
                        ForEach(viewModel.topLevelCategories) { category in
                            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.medium) {
                                Text(viewModel.getDisplayName(for: category))
                                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h3, weight: .bold))
                                
                                NavigationLink(value: category) {
                                    CategoryCardView(category: category, style: .imageOnly)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            if viewModel.topLevelCategories.isEmpty {
                await viewModel.loadInitialData()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo_your_garden_eden_transparent")
                    .resizable().scaledToFit().frame(height: 150)
            }
        }
    }
}
