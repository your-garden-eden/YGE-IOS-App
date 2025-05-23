// YGE-IOS-App/Features/Products/ProductListView.swift
import SwiftUI

struct ProductListView: View {
    let categoryId: Int
    let categoryName: String

    @StateObject private var viewModel = ProductListViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Lade Produkte...")
            } else if let errorMessage = viewModel.errorMessage {
                Text("Fehler: \(errorMessage)").foregroundColor(.red).padding()
                Button("Erneut versuchen") {
                    // Sicherstellen, dass currentCategoryId im ViewModel korrekt gesetzt ist
                    viewModel.fetchProducts(categoryId: categoryId, initialLoad: true)
                }
            } else if viewModel.products.isEmpty {
                Text("Keine Produkte in dieser Kategorie gefunden.")
                    .padding()
            } else {
                List {
                    ForEach(viewModel.products) { product in
                        // ProductRow verwendet jetzt NavigationLink(value:), wenn Product Hashable ist
                        NavigationLink(value: product) { // Navigiert mit dem Product-Objekt
                             ProductRowView(product: product) // Umbenannt zu ProductRowView zur Klarheit
                        }
                        .onAppear {
                            viewModel.loadMoreContentIfNeeded(currentItem: product)
                        }
                    }
                    if viewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationTitle(categoryName)
        .navigationDestination(for: WooCommerceProduct.self) { product in
             // Ziel für die Produkt-Navigation
             ProductDetailView(productSlug: product.slug)
        }
        .onAppear {
            // Nur laden, wenn Kategorie-ID neu oder Produkte leer und nicht schon geladen wird
            if viewModel.currentCategoryId != categoryId || (viewModel.products.isEmpty && !viewModel.isLoading && !viewModel.isLoadingMore) {
                viewModel.fetchProducts(categoryId: categoryId, initialLoad: true)
            }
        }
    }
}

// Umbenannt zu ProductRowView, um Konflikte mit einer möglichen ProductRow-Datei zu vermeiden
// und um klarzustellen, dass dies die Ansicht für eine Zeile ist.
struct ProductRowView: View {
    let product: WooCommerceProduct

    var body: some View {
        // Das NavigationLink wurde in die ProductListView verschoben
        HStack {
            // AsyncImage für Produktbild
            if let firstImage = product.images.first, let imageUrl = URL(string: firstImage.src) {
                AsyncImage(url: imageUrl) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fit)
                    } else if phase.error != nil {
                        Image(systemName: "photo") // Platzhalter bei Fehler
                            .resizable().aspectRatio(contentMode: .fit).opacity(0.3)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 70, height: 70)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)).frame(width: 70, height: 70)
                    .overlay(Image(systemName: "photo").font(.title).opacity(0.3))
            }

            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                Text("Preis: \(product.price) \(product.metaData.first(where: {$0.key == "_currency_symbol"})?.value as? String ?? "€")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer() // Sorgt dafür, dass der Inhalt nach links gedrückt wird
        }
        .padding(.vertical, 4) // Etwas Abstand für die Zeilen
    }
}
