// Core/Categories/Views/CategoryListView.swift
import SwiftUI

struct CategoryListView: View {
    // Verwende @StateObject für die Erstellung und Verwaltung des ViewModels in dieser View.
    @StateObject private var viewModel = CategoryViewModel() // Unser Core CategoryViewModel
    
    var body: some View {
        // Die NavigationStack wird wahrscheinlich von der übergeordneten TabView bereitgestellt,
        // aber für eine eigenständige Preview oder wenn dies der Root einer Navigation ist, ist sie hier richtig.
        // Wenn dies ein Tab-Inhalt ist, könnte die NavigationStack auch hier bleiben oder in der Tab-Container-View sein.
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.categories.isEmpty {
                    ProgressView("Lade Kategorien...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: AppStyles.Spacing.medium) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.error)
                        Text("Fehler")
                            .font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .semibold))
                        Text(errorMessage)
                            .font(AppFonts.roboto(size: AppFonts.Size.body))
                            .foregroundColor(AppColors.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Erneut versuchen") {
                            viewModel.fetchMainCategories()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.primary)
                        .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else if viewModel.categories.isEmpty {
                    Text("Keine Hauptkategorien gefunden.")
                        .font(AppFonts.roboto(size: AppFonts.Size.headline))
                        .foregroundColor(AppColors.textMuted)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Zentrieren
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.categories) { category in
                            // NavigationLink mit dem 'value' der Kategorie
                            NavigationLink(value: category) {
                                // Wir verwenden hier die ProductCategoryRow, die du bereits definiert hast.
                                // Stelle sicher, dass sie mit AppColors, AppFonts etc. kompatibel ist.
                                ProductCategoryRow(category: category)
                            }
                        }
                    }
                    .listStyle(.plain) // Für ein klares Aussehen
                }
            }
            .navigationTitle("Kategorien") // Titel für diese Ansicht
            .navigationBarTitleDisplayMode(.large) // Großer Titel für Kategorieseiten
            .toolbarBackground(AppColors.backgroundPage.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .background(AppColors.backgroundPage.ignoresSafeArea()) // Hintergrund für die gesamte View
            .onAppear {
                // Lade Kategorien nur, wenn die Liste leer ist UND nicht bereits geladen wird.
                if viewModel.categories.isEmpty && !viewModel.isLoading {
                    viewModel.fetchMainCategories()
                }
            }
            .refreshable { // Pull-to-refresh
                viewModel.fetchMainCategories()
            }
            // Navigation Destination für WooCommerceCategory-Objekte
            .navigationDestination(for: WooCommerceCategory.self) { category in
                // Zielansicht, wenn eine Kategorie im navigationPath ist
                ProductListView( // Diese View kommt aus Features/Products/Views/
                    categoryId: category.id,
                    categoryName: category.name
                )
            }
        }
    }
}

// Preview Provider
struct CoreCategoryListView_Previews: PreviewProvider { // Name geändert, um Konflikte zu vermeiden
    static var previews: some View {
        CategoryListView()
            // Hier könntest du ein CategoryViewModel mit Mock-Daten für die Preview injizieren.
            // .environmentObject(CategoryViewModelWithMockData()) // Beispiel
    }
}
