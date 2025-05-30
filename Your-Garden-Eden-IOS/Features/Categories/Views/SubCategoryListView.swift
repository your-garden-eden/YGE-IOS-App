//
//  SubCategoryListView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 30.05.25.
//


// Features/Categories/Views/SubCategoryListView.swift
import SwiftUI

struct SubCategoryListView: View {
    @StateObject private var viewModel: SubCategoryViewModel
    
    // Die WooCommerce-ID der übergeordneten Hauptkategorie, wird benötigt,
    // um die Unterkategorien initial zu laden.
    private let parentWooCommerceCategoryID: Int

    // Initializer
    // Nimmt das AppNavigationItem der ausgewählten Hauptkategorie
    // und die WooCommerce-ID dieser Hauptkategorie entgegen.
    init(selectedMainCategoryAppItem: AppNavigationItem, parentWooCommerceCategoryID: Int) {
        _viewModel = StateObject(wrappedValue: SubCategoryViewModel(appNavigationItem: selectedMainCategoryAppItem))
        self.parentWooCommerceCategoryID = parentWooCommerceCategoryID
    }

    var body: some View {
        Group { // Group, damit Modifier wie .navigationTitle funktionieren
            if viewModel.isLoading && viewModel.displayableSubCategories.isEmpty {
                ProgressView("Lade Unterkategorien...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else if viewModel.displayableSubCategories.isEmpty {
                // Dieser Fall tritt ein, wenn keine SubItems definiert waren
                // oder keine Matches gefunden wurden (und isLoading false ist).
                Text("Keine Unterkategorien verfügbar.")
                    .font(AppFonts.roboto(size: AppFonts.Size.headline))
                    .foregroundColor(AppColors.textMuted)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                listContent
            }
        }
        .navigationTitle(viewModel.navigationTitle) // Titel aus dem ViewModel
        .navigationBarTitleDisplayMode(.large)
        .background(AppColors.backgroundPage.ignoresSafeArea())
        .task { // .task statt .onAppear für asynchrone Operationen bei Erscheinen
            // Lade Unterkategorien nur, wenn sie noch nicht geladen wurden
            // oder wenn ein Fehler vorlag und erneut versucht wird (implizit durch View-Neuerstellung).
            if viewModel.displayableSubCategories.isEmpty && viewModel.errorMessage == nil {
                viewModel.fetchSubCategories(parentWooCommerceCategoryID: parentWooCommerceCategoryID)
            }
        }
        .refreshable {
            print("SubCategoryListView: Pull-to-refresh triggered.")
            viewModel.fetchSubCategories(parentWooCommerceCategoryID: parentWooCommerceCategoryID)
        }
        // Navigation Destination für DisplayableSubCategory
        // Wir navigieren basierend auf dem DisplayableSubCategory Objekt
        .navigationDestination(for: DisplayableSubCategory.self) { subCategoryItem in
            // Stelle sicher, dass wir eine wooCommerceCategoryID haben, um zur ProductListView zu navigieren
            if let categoryId = subCategoryItem.wooCommerceCategoryID {
                ProductListView(
                    categoryId: categoryId,
                    categoryName: subCategoryItem.label // Verwende das Label aus AppNavigationData
                )
            } else {
                // Fallback, falls keine WooCommerce-ID gefunden wurde (sollte nicht oft passieren, wenn Slugs matchen)
                Text("Produkte für \(subCategoryItem.label) konnten nicht geladen werden (fehlende Kategorie-ID).")
                    .padding()
                    .navigationTitle(subCategoryItem.label)
            }
        }
    }

    private var listContent: some View {
        List {
            ForEach(viewModel.displayableSubCategories) { subCat in
                // NavigationLink, der das DisplayableSubCategory-Objekt als Wert übergibt
                NavigationLink(value: subCat) {
                    SubCategoryRow(subCategoryDisplayItem: subCat)
                }
            }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(AppColors.error)
            Text("Fehler")
                .font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .semibold))
            Text(message)
                .font(AppFonts.roboto(size: AppFonts.Size.body))
                .foregroundColor(AppColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Erneut versuchen") {
                viewModel.fetchSubCategories(parentWooCommerceCategoryID: parentWooCommerceCategoryID)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.primary)
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// Eine neue View für die Darstellung einer einzelnen Unterkategorie-Zeile
struct SubCategoryRow: View {
    let subCategoryDisplayItem: DisplayableSubCategory

    var body: some View {
        HStack(spacing: AppStyles.Spacing.medium) {
            if let iconName = subCategoryDisplayItem.iconName {
                Image(iconName) // Bild aus Assets basierend auf iconFilename
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50) // Beispielgröße, anpassen
                    .padding(AppStyles.Spacing.xSmall)
                    .background(AppColors.backgroundLightGray) // Leichter Hintergrund für das Icon
                    .cornerRadius(AppStyles.BorderRadius.small)
            } else {
                // Fallback, falls kein Icon definiert ist
                Image(systemName: "tag.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .padding(AppStyles.Spacing.xSmall)
                    .foregroundColor(AppColors.textMuted)
                    .background(AppColors.backgroundLightGray)
                    .cornerRadius(AppStyles.BorderRadius.small)
            }
            
            Text(subCategoryDisplayItem.label)
                .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .medium))
                .foregroundColor(AppColors.textHeadings)
            
            Spacer()
            
            // Zeige ein Chevron nur, wenn tatsächlich navigiert werden kann (ID vorhanden)
            if subCategoryDisplayItem.wooCommerceCategoryID != nil {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .padding(.vertical, AppStyles.Spacing.small)
        // Blasse die Zeile aus, wenn keine WooCommerce-ID gefunden wurde, um zu signalisieren,
        // dass hier keine Produkte geladen werden können.
        .opacity(subCategoryDisplayItem.wooCommerceCategoryID == nil ? 0.5 : 1.0)
    }
}