import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    private var gridItemLayout = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    ZStack {
                        Color.gray.opacity(0.2)
                            .frame(height: 200)
                            .cornerRadius(12)
                        Text("Your Garden Eden - Banner")
                            .font(.title)
                            .foregroundColor(.primary.opacity(0.7))
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("Unsere Empfehlungen")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<5) { index in
                                    ProductCardPlaceholderView(title: "Produkt \(index + 1)")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("Kategorien entdecken")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: gridItemLayout, spacing: 16) {
                            ForEach(0..<4) { index in
                                 CategoryTilePlaceholderView(title: "Kategorie \(index + 1)")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView("Lade Daten...")
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text("Fehler: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Home")
            // .onAppear {
            //    viewModel.loadDataForHomeView()
            // }
            // .navigationDestination(for: WooCommerceProduct.self) { product in
            //     // ProductDetailView(product: product) // Später definieren
            //     Text("Detailansicht für \(product.name)")
            // }
        }
    }
}

// Platzhalter-View für Produktkarten
struct ProductCardPlaceholderView: View {
    let title: String
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.3))
                .frame(width: 150, height: 120)
            Text(title)
                .font(.headline)
            Text("€19,99")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(width: 150)
        .padding(8)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

// Platzhalter-View für Kategorie-Kacheln
struct CategoryTilePlaceholderView: View {
    let title: String
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green.opacity(0.3))
                .aspectRatio(1, contentMode: .fit)
            Text(title)
                .font(.headline)
        }
        .padding(8)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
