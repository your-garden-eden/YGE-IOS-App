//
//  CategoryListView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//

import SwiftUI

struct CategoryListView: View {
    @StateObject private var viewModel = CategoryViewModel()

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
        // --- START KORREKTUR ---
        // .onAppear wurde durch .task ersetzt.
        // .task ist der moderne und sichere Weg, um asynchrone Operationen
        // beim Erscheinen einer View zu starten. Es verhindert die "AttributeGraph"-Zyklen.
        .task {
            if viewModel.categories.isEmpty {
                 viewModel.fetchMainCategories()
            }
        }
        // --- ENDE KORREKTUR ---
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
                // Wir stellen sicher, dass der slug nicht leer ist, bevor wir den Link erstellen.
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
