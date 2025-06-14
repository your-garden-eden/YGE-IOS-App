// Path: Your-Garden-Eden-IOS/Features/Categories/CategoryListView.swift
// FINALE, VOLLSTÄNDIGE VERSION

import SwiftUI

struct CategoryListView: View {
    // Greift auf den globalen, zentralen ViewModel zu.
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
        // Das Laden der Daten geschieht jetzt zentral in der ContentView und wird nicht mehr hier ausgelöst.
    }
    
    @ViewBuilder
    private var contentView: some View {
        // Die Logik hier prüft jetzt auf 'displayableCategories' statt 'categories'.
        if viewModel.isLoading && viewModel.displayableCategories.isEmpty {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            // Wir verwenden hier die neue, wiederverwendbare ErrorStateView
            ErrorStateView(message: errorMessage)
        } else if viewModel.displayableCategories.isEmpty && !viewModel.isLoading {
            emptyView
        } else {
            categoryList
        }
    }
    
    private var categoryList: some View {
        List {
            // Wir iterieren jetzt über die aufbereiteten 'displayableCategories'.
            ForEach(viewModel.displayableCategories) { displayableCategory in
                
                // Wir erstellen den NavigationLink, dessen 'value' ein
                // 'DisplayableMainCategory' ist, das unser NavigationStack verarbeiten kann.
                NavigationLink(value: displayableCategory) {
                    // KORREKTER AUFRUF: Wir übergeben jetzt alle benötigten Parameter.
                    // 'imageUrl' ist hier `nil`, da unsere Hauptkategorien ihre Bilder
                    // aus den lokalen App-Assets beziehen, die im `appItem` definiert sind.
                    ProductCategoryRow(
                        label: displayableCategory.appItem.label,
                        imageUrl: nil,
                        localImageFilename: displayableCategory.appItem.imageFilename
                    )
                }
            }
            .listRowInsets(EdgeInsets(top: AppStyles.Spacing.small, leading: AppStyles.Spacing.medium, bottom: AppStyles.Spacing.small, trailing: AppStyles.Spacing.medium))
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
    
    private var emptyView: some View {
        Text("Keine Kategorien gefunden.")
            .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular))
            .foregroundColor(AppColors.textMuted)
    }
}
