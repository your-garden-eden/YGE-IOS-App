// YGE-IOS-App/Features/Categories/Views/ProductCategoryListView.swift

import SwiftUI

// Annahme: Deine Modelle WooCommerceCategory, WooCommerceImage und die
// String+Extensions.swift (mit strippingHTML) sind jetzt Teil deines Projekts.

struct ProductCategoryListView: View {
    @StateObject private var viewModel = ProductCategoryListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.categories.isEmpty {
                    ProgressView("Lade Kategorien...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                        Text("Fehler")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Erneut versuchen") {
                            Task {
                                await viewModel.loadCategories()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.categories.isEmpty {
                    Text("Keine Kategorien gefunden.")
                        .foregroundColor(.secondary)
                        .padding()
                        .multilineTextAlignment(.center)
                    Button("Kategorien laden") {
                        Task {
                            await viewModel.loadCategories()
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 5)
                } else {
                    List {
                        ForEach(viewModel.categories) { category in
                            NavigationLink(value: category) {
                                ProductCategoryRow(category: category)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Kategorien")
            .onAppear {
                if viewModel.categories.isEmpty && !viewModel.isLoading {
                    Task {
                        print("ProductCategoryListView: .onAppear - loading categories.")
                        await viewModel.loadCategories()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading && !viewModel.categories.isEmpty {
                        ProgressView()
                    } else {
                        Button {
                            Task {
                                await viewModel.loadCategories()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .help("Kategorien neu laden")
                        .disabled(viewModel.isLoading)
                    }
                }
            }
            .navigationDestination(for: WooCommerceCategory.self) { category in
                ProductListView(categoryId: category.id, categoryName: category.name)
            }
        }
    }
}

struct ProductCategoryRow: View {
    let category: WooCommerceCategory

    var body: some View {
        HStack(spacing: 12) {
            if let imageUrlString = category.image?.src, let imageUrl = URL(string: imageUrlString) {
                 AsyncImage(url: imageUrl) { phase in
                     switch phase {
                     case .empty:
                         ProgressView()
                             .frame(width: 50, height: 50)
                     case .success(let image):
                         image.resizable()
                              .aspectRatio(contentMode: .fill)
                              .frame(width: 50, height: 50)
                              .clipShape(RoundedRectangle(cornerRadius: 8))
                     case .failure:
                         Image(systemName: "photo.on.rectangle.angled")
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .foregroundColor(.gray)
                             .frame(width: 50, height: 50) // Konsistenter Frame
                             .padding(10) // Padding innerhalb des Rahmens
                             .background(Color.gray.opacity(0.1))
                             .clipShape(RoundedRectangle(cornerRadius: 8))
                     @unknown default:
                         EmptyView()
                     }
                 }
                 .frame(width: 50, height: 50) // Sicherstellen, dass der Frame konsistent ist
            } else {
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30) // Größe des Icons
                    .foregroundColor(.secondary)
                    .frame(width: 50, height: 50) // Äußerer Frame für Layout
                    .background(Color(UIColor.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.headline)
                if !category.description.isEmpty { // Nur anzeigen, wenn nicht leer
                    Text(category.description.strippingHTML())
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Text("\(category.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(UIColor.systemGray6))
                .clipShape(Capsule())
        }
        .padding(.vertical, 6)
    }
}

struct ProductCategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        // Erstelle Mock-Daten für die Preview
        let mockViewModel = ProductCategoryListViewModel()
        
        // Beispielhafte WooCommerceImage Instanz für die Preview
        // let exampleImage = WooCommerceImage(id: 1, dateCreated: nil, dateCreatedGmt: nil, dateModified: nil, dateModifiedGmt: nil, src: "https://your-garden-eden-4ujzpfm5qt.live-website.com/wp-content/uploads/2024/03/pexels-lisa-fotios-1090638-scaled.jpg", name: "Beispielbild", alt: "Ein Beispiel", position: 0)
        
        // Beispielhafte WooCommerceCategory Instanzen für die Preview
        // mockViewModel.categories = [
        //     WooCommerceCategory(id: 1, name: "Gartenwerkzeuge", slug: "gartenwerkzeuge", parent: 0, description: "Alles für die Gartenarbeit <i>effizient</i> erledigen.", display: "default", image: exampleImage, menuOrder: 1, count: 42),
        //     WooCommerceCategory(id: 2, name: "Pflanzen", slug: "pflanzen", parent: 0, description: "Grüne und blühende Vielfalt für Ihr Zuhause.", display: "products", image: nil, menuOrder: 2, count: 120),
        //     WooCommerceCategory(id: 3, name: "Dekoration", slug: "dekoration", parent: 0, description: "", display: "default", image: nil, menuOrder: 3, count: 75) // Leere Beschreibung
        // ]
        // mockViewModel.isLoading = false
        // mockViewModel.errorMessage = nil
        
        return ProductCategoryListView()
            .environmentObject(mockViewModel) // Kann verwendet werden, um das ViewModel in die Preview zu injizieren
    }
}
