// YGE-IOS-App/Features/Categories/Views/CategoryListView.swift
import SwiftUI

struct CategoryListView: View {
    // Verwende @StateObject für die Erstellung und Verwaltung des ViewModels in dieser View.
    @StateObject private var viewModel = CategoryViewModel()
    
    // Für die programmatische Navigation mit NavigationStack
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group { // Group, um die Logik für verschiedene Zustände klarer zu trennen
                if viewModel.isLoading && viewModel.categories.isEmpty { // Zeige Ladeindikator nur beim ersten Laden oder wenn Liste leer ist
                    ProgressView("Lade Kategorien...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Zentrieren
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Fehler")
                            .font(.title2.bold())
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Erneut versuchen") {
                            viewModel.fetchCategories() // Ruft Hauptkategorien erneut ab
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Zentrieren
                } else if viewModel.categories.isEmpty {
                    Text("Keine Kategorien gefunden.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Zentrieren
                } else {
                    List {
                        ForEach(viewModel.categories) { category in
                            // NavigationLink mit dem 'value' der Kategorie
                            NavigationLink(value: category) {
                                CategoryRow(category: category) // Eigene View für die Zeile
                            }
                        }
                    }
                    // Optional: Pull-to-refresh Funktionalität
                    // .refreshable {
                    //     viewModel.fetchCategories()
                    // }
                }
            }
            .navigationTitle("Kategorien")
            .navigationDestination(for: WooCommerceCategory.self) { category in
                // Zielansicht, wenn eine Kategorie im navigationPath ist
                ProductListView(
                    categoryId: category.id,
                    categoryName: category.name
                )
            }
            .onAppear {
                // Lade Kategorien nur, wenn die Liste leer ist UND nicht bereits geladen wird.
                // Dies verhindert Neuladen beim Zurücknavigieren, wenn Daten schon da sind.
                if viewModel.categories.isEmpty && !viewModel.isLoading {
                    viewModel.fetchCategories() // Lädt Hauptkategorien (parent: nil)
                }
            }
            // Optional: Toolbar-Button zum erneuten Laden
            // .toolbar {
            //     ToolbarItem(placement: .navigationBarTrailing) {
            //         if viewModel.isLoading {
            //             ProgressView()
            //         } else {
            //             Button {
            //                 viewModel.fetchCategories()
            //             } label: {
            //                 Image(systemName: "arrow.clockwise")
            //             }
            //         }
            //     }
            // }
        }
    }
}

// Eine separate View für die Darstellung einer einzelnen Kategorie-Zeile
struct CategoryRow: View {
    let category: WooCommerceCategory

    var body: some View {
        HStack {
            // Optional: Kategoriebild mit AsyncImage
            if let imageUrlString = category.image?.src, let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fit)
                    } else if phase.error != nil {
                        Image(systemName: "photo.fill") // Fehler-Icon
                            .foregroundColor(.gray)
                    } else {
                        Color.gray.opacity(0.1) // Platzhalter-Farbe während des Ladens
                    }
                }
                .frame(width: 44, height: 44)
                .background(Color(UIColor.systemGray6)) // Hintergrund für den Bildbereich
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // Platzhalter, wenn kein Bild vorhanden ist
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: 44, height: 44)
                    .overlay(Image(systemName: "tag.fill").foregroundColor(.gray))
            }

            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.headline)
                if category.count > 0 {
                    Text("\(category.count) Produkte")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            // Der Chevron für den NavigationLink wird automatisch hinzugefügt
        }
        .padding(.vertical, 4) // Etwas vertikaler Abstand für jede Zeile
    }
}

// Preview Provider (optional, aber hilfreich)
struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryListView()
            // Hier könntest du ein CategoryViewModel mit Mock-Daten für die Preview injizieren,
            // wenn dein WooCommerceCategory.placeholder existiert.
            // .environmentObject(CategoryViewModelWithMockData())
    }
}
