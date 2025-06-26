// DATEI: ProductListView.swift
// PFAD: Features/Products/Views/List/ProductListView.swift
// VERSION: 1.1 (FINAL)

import SwiftUI

struct ProductListView: View {
    
    @StateObject private var viewModel: ProductListViewModel
    @State private var searchText: String = ""
    @State private var isFilterSheetPresented = false

    init(category: WooCommerceCategory) {
        _viewModel = StateObject(wrappedValue: ProductListViewModel(context: .categoryId(category.id)))
    }

    init(context: ProductListContext, headline: String) {
        _viewModel = StateObject(wrappedValue: ProductListViewModel(context: context, headline: headline))
    }

    var body: some View {
        VStack(spacing: 0) {
            searchAndFilterBar
                .padding([.horizontal, .bottom])
                .padding(.top, 8)
                .background(AppTheme.Colors.backgroundPage)

            ZStack {
                AppTheme.Colors.backgroundPage.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.products.isEmpty {
                    ProgressView().tint(AppTheme.Colors.primary)
                } else if let errorMessage = viewModel.errorMessage {
                    StatusIndicatorView.errorState(message: errorMessage)
                } else if viewModel.products.isEmpty {
                     emptyOrSearchEmptyView
                } else {
                    productGrid
                }
            }
        }
        .task {
            if viewModel.products.isEmpty {
                await viewModel.loadProducts()
            }
        }
        .navigationTitle(viewModel.headline ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isFilterSheetPresented) {
            FilterView(filterState: viewModel.filterState, isPresented: $isFilterSheetPresented) {
                viewModel.applyFilters()
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) {
            viewModel.search(for: searchText)
        }
    }
    
    private var searchAndFilterBar: some View {
        HStack {
            // Suchleiste wurde in die Navigation integriert via .searchable
            Spacer()
            Button { isFilterSheetPresented = true } label: {
                Label("Filter", systemImage: "slider.horizontal.3")
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.Colors.primaryDark)
        }
    }

    private var productGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(viewModel.products) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product)
                            .onAppear {
                                if product.id == viewModel.products.last?.id {
                                    Task { await viewModel.loadMoreProducts() }
                                }
                            }
                    }
                }
            }
            .padding()
            
            if viewModel.isLoadingMore { ProgressView().padding() }
        }
    }
    
    @ViewBuilder
    private var emptyOrSearchEmptyView: some View {
        if !searchText.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "magnifyingglass").font(.system(size: 60)).foregroundColor(AppTheme.Colors.primary.opacity(0.5))
                Text("Keine Treffer").font(AppTheme.Fonts.montserrat(size: 22, weight: .bold))
                Text("Für deine Suche nach \"\(searchText)\" wurden keine Produkte gefunden.").font(AppTheme.Fonts.roboto(size: 16)).foregroundColor(AppTheme.Colors.textMuted).multilineTextAlignment(.center)
            }.padding()
        } else {
            VStack(spacing: 16) {
                Image(systemName: "bag.fill").font(.system(size: 60)).foregroundColor(AppTheme.Colors.primary.opacity(0.5))
                Text("Keine Produkte").font(AppTheme.Fonts.montserrat(size: 22, weight: .bold))
                Text("In dieser Kategorie wurden leider keine Produkte gefunden.").font(AppTheme.Fonts.roboto(size: 16)).foregroundColor(AppTheme.Colors.textMuted).multilineTextAlignment(.center)
                Button("Filter zurücksetzen") { viewModel.resetFilters() }.buttonStyle(AppTheme.PrimaryButtonStyle()).padding(.top)
            }.padding()
        }
    }
}
