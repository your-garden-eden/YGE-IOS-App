// Dateiname: CategoryListView.swift
// FINALE, KORRIGIERTE VERSION

import SwiftUI

struct CategoryListView: View {
    // Greift auf den globalen, zentralen ViewModel zu. Das ist korrekt.
    @EnvironmentObject private var viewModel: CategoryViewModel

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
        // DER .task-BLOCK WIRD VOLLSTÄNDIG ENTFERNT.
        // Das Laden der Daten geschieht jetzt automatisch im ViewModel.
        // Das macht diesen Code sauberer und robuster.
    }
    
    @ViewBuilder
    private var contentView: some View {
        // Die Logik hier prüft jetzt auf 'displayableCategories' statt 'categories'.
        if viewModel.isLoading && viewModel.displayableCategories.isEmpty {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else if viewModel.displayableCategories.isEmpty && !viewModel.isLoading {
            emptyView
        } else {
            categoryList
        }
    }
    
    private var categoryList: some View {
        List {
            // KORREKTUR: Wir iterieren jetzt über 'displayableCategories'.
            ForEach(viewModel.displayableCategories) { displayableCategory in
                
                // Wir erstellen den NavigationLink, dessen 'value' ein
                // 'DisplayableMainCategory' ist. Die Navigations-Erweiterung in
                // ContentView kann diesen Typ verarbeiten.
                NavigationLink(value: displayableCategory) {
                    ProductCategoryRow(
                        // Die Daten für die Row kommen jetzt aus dem 'appItem'
                        // innerhalb der 'displayableCategory'.
                        label: displayableCategory.appItem.label,
                        imageUrl: nil, // Note: WooCommerceCategory image ist nicht mehr direkt hier
                        localImageFilename: displayableCategory.appItem.imageFilename
                    )
                }
            }
            .listRowInsets(EdgeInsets(top: AppStyles.Spacing.small, leading: AppStyles.Spacing.large, bottom: AppStyles.Spacing.small, trailing: AppStyles.Spacing.large))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    // Die folgenden Helper-Views bleiben unverändert.
    
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
