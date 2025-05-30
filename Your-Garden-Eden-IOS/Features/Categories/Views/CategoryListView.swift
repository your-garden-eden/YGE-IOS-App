// Core/Categories/Views/CategoryListView.swift
import SwiftUI

struct CategoryListView: View {
    @StateObject private var viewModel = CategoryViewModel()
    
    var body: some View {
        NavigationStack { // Behalte die NavigationStack hier für eine saubere Hierarchie
            Group {
                if viewModel.isLoading && viewModel.categories.isEmpty {
                    ProgressView("Lade Kategorien...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    // Fehleransicht (wie zuvor)
                    VStack(spacing: AppStyles.Spacing.medium) {
                        Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 40)).foregroundColor(AppColors.error)
                        Text("Fehler").font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .semibold))
                        Text(errorMessage).font(AppFonts.roboto(size: AppFonts.Size.body)).foregroundColor(AppColors.textMuted).multilineTextAlignment(.center).padding(.horizontal)
                        Button("Erneut versuchen") { viewModel.fetchMainCategories() }
                        .buttonStyle(.borderedProminent).tint(AppColors.primary).padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity).padding()
                } else if viewModel.categories.isEmpty {
                    Text("Keine Hauptkategorien gefunden.")
                        .font(AppFonts.roboto(size: AppFonts.Size.headline))
                        .foregroundColor(AppColors.textMuted)
                        .frame(maxWidth: .infinity, maxHeight: .infinity).padding()
                } else {
                    listContent
                }
            }
            .navigationTitle("Kategorien")
            .navigationBarTitleDisplayMode(.large)
            // Optional: Anpassung der Toolbar-Farbe, falls gewünscht
            // .toolbarBackground(AppColors.backgroundPage.opacity(0.8), for: .navigationBar)
            // .toolbarBackground(.visible, for: .navigationBar)
            .background(AppColors.backgroundPage.ignoresSafeArea())
            .onAppear {
                if viewModel.categories.isEmpty && !viewModel.isLoading {
                    viewModel.fetchMainCategories()
                }
            }
            .refreshable {
                viewModel.fetchMainCategories()
            }
            // NEUE Navigation Destination: Wir navigieren jetzt mit dem AppNavigationItem
            .navigationDestination(for: AppNavigationItem.self) { appNavItem in
                // Hier wird die WooCommerce-ID der Hauptkategorie benötigt.
                // Wir finden die entsprechende WooCommerceCategory aus dem ViewModel,
                // um deren ID an SubCategoryListView zu übergeben.
                if let selectedWooCategory = viewModel.categories.first(where: { $0.slug == appNavItem.mainCategorySlug }) {
                    SubCategoryListView(
                        selectedMainCategoryAppItem: appNavItem,
                        parentWooCommerceCategoryID: selectedWooCategory.id
                    )
                } else {
                    // Fallback, falls die WooCommerce-Kategorie nicht gefunden wurde (sollte nicht passieren, wenn Slugs übereinstimmen)
                    Text("Details für \(appNavItem.label) konnten nicht geladen werden.")
                        .navigationTitle(appNavItem.label)
                }
            }
        }
    }
    
    private var listContent: some View {
        List {
            ForEach(viewModel.categories) { wooCategory in
                // Finde das passende AppNavigationItem für die aktuelle WooCommerce-Kategorie
                // anhand des Slugs.
                if let appNavItem = AppNavigationData.findItem(forMainCategorySlug: wooCategory.slug) {
                    // NavigationLink mit dem 'value' des AppNavigationItem
                    NavigationLink(value: appNavItem) {
                        ProductCategoryRow(category: wooCategory) // Bestehende Row-View verwenden
                    }
                } else {
                    // Zeige die Kategorie trotzdem an, aber ohne funktionierende Navigation zu Unterkategorien,
                    // falls kein passendes AppNavigationItem gefunden wurde.
                    // Dies ist ein Hinweis auf eine Inkonsistenz zwischen API-Daten und AppNavigationData.
                    HStack {
                        ProductCategoryRow(category: wooCategory)
                        Spacer()
                        Image(systemName: "exclamationmark.circle.fill").foregroundColor(.orange)
                    }
                    .onTapGesture {
                        print("CategoryListView: WARNING - Kein AppNavigationItem für WooCommerce-Kategorie '\(wooCategory.name)' (Slug: \(wooCategory.slug)) gefunden. Navigation zu Unterkategorien nicht möglich.")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

// Preview Provider (Name ggf. angepasst, falls schon vorhanden)
struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryListView()
            .environmentObject(FirebaseAuthManager.shared) // Falls benötigt für Sub-Views oder Auth-Flows
            // .environmentObject(AppNavigationData()) // Nicht nötig, da statisch
    }
}
