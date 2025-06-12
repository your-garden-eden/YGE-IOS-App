//
//  CategoryListView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//

import SwiftUI

struct CategoryListView: View {
    // --- START ÄNDERUNG 1.1 ---
    // @StateObject wird durch @EnvironmentObject ersetzt.
    // Die View erstellt den ViewModel nicht mehr selbst, sondern empfängt die zentrale,
    // in der App-Datei erstellte Instanz. Dies ist der entscheidende Schritt zur
    // Behebung der UI-Zyklen.
    @EnvironmentObject private var viewModel: CategoryViewModel
    // --- ENDE ÄNDERUNG 1.1 ---

    var body: some View {
        ZStack {
            AppColors.backgroundPage.ignoresSafeArea()
            contentView
        }
        .navigationTitle("Shop")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Shop")
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)
            }
        }
        .task {
            // Dieser Aufruf ist jetzt sicher, da er auf dem stabilen,
            // zentralen ViewModel ausgeführt wird.
            if viewModel.categories.isEmpty {
                 viewModel.fetchMainCategories()
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.categories.isEmpty {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else if viewModel.categories.isEmpty && !viewModel.isLoading {
            emptyView
        } else {
            categoryList
        }
    }
    
    private var categoryList: some View {
        List {
            ForEach(viewModel.categories) { wooCategory in
                if let navItem = AppNavigationData.findItem(forMainCategorySlug: wooCategory.slug), !wooCategory.slug.isEmpty {
                    NavigationLink(value: wooCategory) {
                        ProductCategoryRow(
                            label: navItem.label,
                            imageUrl: wooCategory.image?.src.asURL(),
                            localImageFilename: navItem.imageFilename
                        )
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: AppStyles.Spacing.small, leading: AppStyles.Spacing.large, bottom: AppStyles.Spacing.small, trailing: AppStyles.Spacing.large))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private var loadingView: some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            ProgressView().tint(AppColors.primary)
            Text("Lade Kategorien...")
                .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular))
                .foregroundColor(AppColors.textMuted)
        }
    }
    
    private func errorView(message: String) -> some View {
        Text(message)
            .foregroundColor(AppColors.error)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    private var emptyView: some View {
        Text("Keine Kategorien gefunden.")
            .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular))
            .foregroundColor(AppColors.textMuted)
    }
}
