// Path: Your-Garden-Eden-IOS/Features/Products/Views/ProductListView.swift
// VERSION 2.3 (Integrated with real FilterView)

import SwiftUI

struct ProductListView: View {
    
    @StateObject private var viewModel: ProductListViewModel
    private let navigationBarTitle: String

    // NEU: Ein State-Objekt, das den Zustand aller Filter hält.
    @StateObject private var filterState = ProductFilterState()
    
    @State private var searchText = ""
    @State private var isFilterSheetPresented = false

    init(category: WooCommerceCategory) {
        let displayName = Self.findLabelFor(category: category)
        self.navigationBarTitle = displayName
        _viewModel = StateObject(wrappedValue: ProductListViewModel(context: .categoryId(category.id), headline: displayName))
    }

    var body: some View {
        VStack(spacing: 0) {
            searchAndFilterBar
                .padding([.horizontal, .bottom], AppStyles.Spacing.medium)
                .padding(.top, AppStyles.Spacing.small)
                .background(AppColors.backgroundPage)

            ZStack {
                AppColors.backgroundPage.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.products.isEmpty {
                    ProgressView().tint(AppColors.primary)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(message: errorMessage)
                } else if viewModel.products.isEmpty {
                    if viewModel.context == .search("") || (viewModel.context != .search("") && searchText.isEmpty) {
                        emptyView
                    } else {
                        searchEmptyView
                    }
                } else {
                    productGrid
                }
            }
        }
        .task {
            if viewModel.products.isEmpty && searchText.isEmpty {
                await viewModel.loadProducts()
            }
        }
        .navigationTitle(navigationBarTitle)
        .navigationBarTitleDisplayMode(.inline)
        // ===================================================================
        // **KORREKTUR: Der Platzhalter wird durch die echte FilterView ersetzt.**
        // ===================================================================
        .sheet(isPresented: $isFilterSheetPresented) {
            FilterView(
                filterState: filterState,
                isPresented: $isFilterSheetPresented,
                onApply: {
                    // Hier kommt in Phase 3 die Logik zum Anwenden der Filter hinzu.
                    print("Filter angewendet! Sortierung: \(filterState.selectedSortOption.rawValue)")
                    print("Preisspanne: \(filterState.currentPriceRange)")
                    print("Attribute: \(filterState.selectedAttributes)")
                    
                    // Beispielhafter Aufruf für Phase 3:
                    // Task { await viewModel.applyFilters(filterState) }
                }
            )
        }
        .onChange(of: searchText) { _, newQuery in
            viewModel.search(for: newQuery)
        }
    }
    
    // --- Rest der Datei bleibt unverändert ---
    
    private var searchAndFilterBar: some View {
        HStack(spacing: AppStyles.Spacing.medium) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textMuted)
                TextField("Produkte durchsuchen...", text: $searchText)
                    .font(AppFonts.montserrat(size: AppFonts.Size.body))
                    .submitLabel(.search)
            }
            .padding(AppStyles.Spacing.small)
            .background(AppColors.backgroundComponent)
            .cornerRadius(AppStyles.BorderRadius.large)
            
            Button {
                isFilterSheetPresented = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .foregroundColor(AppColors.primaryDark)
            }
        }
    }

    private var productGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: AppStyles.Spacing.medium), GridItem(.flexible(), spacing: AppStyles.Spacing.medium)], spacing: AppStyles.Spacing.medium) {
                ForEach(viewModel.products) { product in
                    ProductCardView(product: product)
                        .onAppear {
                            if product.id == viewModel.products.dropLast(5).last?.id && viewModel.canLoadMore {
                                Task { await viewModel.loadMoreProducts() }
                            }
                        }
                }
            }
            .padding()
            
            if viewModel.isLoadingMore {
                ProgressView().padding()
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: AppStyles.Spacing.large) {
            Image(systemName: "bag.fill").font(.system(size: 60)).foregroundColor(AppColors.primary.opacity(0.5))
            Text("Keine Produkte").font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .bold)).foregroundColor(AppColors.textHeadings)
            Text("In dieser Kategorie wurden leider keine Produkte gefunden.").font(AppFonts.roboto(size: AppFonts.Size.body)).foregroundColor(AppColors.textMuted).multilineTextAlignment(.center)
        }.padding()
    }
    
    private var searchEmptyView: some View {
        VStack(spacing: AppStyles.Spacing.large) {
            Image(systemName: "magnifyingglass").font(.system(size: 60)).foregroundColor(AppColors.primary.opacity(0.5))
            Text("Keine Treffer").font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .bold)).foregroundColor(AppColors.textHeadings)
            Text("Für deine Suche nach \"\(searchText)\" wurden keine Produkte gefunden.").font(AppFonts.roboto(size: AppFonts.Size.body)).foregroundColor(AppColors.textMuted).multilineTextAlignment(.center)
        }.padding()
    }
    
    private static func findLabelFor(category: WooCommerceCategory) -> String {
        if let mainItem = AppNavigationData.items.first(where: { $0.mainCategorySlug == category.slug }) {
            return mainItem.label
        }
        for item in AppNavigationData.items {
            if let subItems = item.subItems, let subItem = subItems.first(where: { $0.linkSlug == category.slug }) {
                return subItem.label
            }
        }
        return category.name.strippingHTML()
    }
}
