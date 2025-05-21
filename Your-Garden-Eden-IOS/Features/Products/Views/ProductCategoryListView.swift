import SwiftUI

struct ProductCategoryListView: View {
    @StateObject private var viewModel = ProductCategoryListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Lade Kategorien...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack { Text("Fehler: \(errorMessage)"); Button("Erneut") { viewModel.loadCategories() } }
                } else if viewModel.categories.isEmpty {
                    Text("Keine Kategorien gefunden. Ladefunktion ist ggf. deaktiviert.")
                        .foregroundColor(.secondary)
                        .padding()
                        .multilineTextAlignment(.center)
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
                if viewModel.categories.isEmpty && !viewModel.isLoading { // Nur laden, wenn leer und nicht schon lädt
                    viewModel.loadCategories()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { viewModel.loadCategories() } label: { Image(systemName: "arrow.clockwise") }
                }
            }
            .navigationDestination(for: WooCommerceCategory.self) { category in
                ProductListView(categoryId: category.id, categoryName: category.name)
            }
        }
    }
}

struct ProductCategoryRow: View { // Diese bleibt hier oder in eigener Datei
    let category: WooCommerceCategory
    var body: some View {
        HStack {
            if let imageUrlString = category.image?.src, let imageUrl = URL(string: imageUrlString) {
                 AsyncImage(url: imageUrl) { /* ... AsyncImage Code ... */ phase in
                     if let image = phase.image { image.resizable().aspectRatio(contentMode: .fit) }
                     else if phase.error != nil { Image(systemName: "photo.on.rectangle.angled").resizable().aspectRatio(contentMode: .fit).foregroundColor(.gray) }
                     else { ProgressView() }
                 }
                 .frame(width: 50, height: 50).cornerRadius(8)
            } else {
                Image(systemName: "photo.on.rectangle.angled").resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50).padding(10).background(Color.gray.opacity(0.2)).cornerRadius(8)
            }
            VStack(alignment: .leading) {
                Text(category.name).font(.headline)
                if !category.description.isEmpty { Text(category.description).font(.caption).foregroundColor(.gray).lineLimit(2) }
            }
            Spacer()
            Text("\(category.count)").font(.caption).foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ProductCategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview mit einem ViewModel, das einen leeren oder Placeholder-Status hat
        ProductCategoryListView()
    }
}
