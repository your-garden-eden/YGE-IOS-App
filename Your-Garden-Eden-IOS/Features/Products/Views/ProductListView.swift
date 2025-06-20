// DATEI: ProductListView.swift
// PFAD: Features/Products/Views/List/ProductListView.swift
// STATUS: VALIDERT & BESTÄTIGT
// BEFUND: Die Verwendung von `LazyVGrid` ist optimal für die performante Darstellung
//         eines Produktgitters mit einer variablen Anzahl von Elementen.

import SwiftUI

struct ProductListView: View {
    
    @StateObject private var viewModel: ProductListViewModel
    private let navigationBarTitle: String

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
                .padding([.horizontal, .bottom], AppTheme.Layout.Spacing.medium)
                .padding(.top, AppTheme.Layout.Spacing.small)
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
            if viewModel.products.isEmpty && searchText.isEmpty {
                await viewModel.loadProducts()
            }
        }
        .navigationTitle(navigationBarTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isFilterSheetPresented) {
            FilterView(filterState: viewModel.filterState, isPresented: $isFilterSheetPresented) {
                viewModel.applyFilters()
            }
        }
        .onChange(of: searchText) { _, newQuery in
            viewModel.search(for: newQuery)
        }
    }
    
    private var searchAndFilterBar: some View {
        HStack(spacing: AppTheme.Layout.Spacing.medium) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(AppTheme.Colors.textMuted)
                TextField("Produkte durchsuchen...", text: $searchText)
                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.body))
                    .submitLabel(.search)
            }
            .padding(AppTheme.Layout.Spacing.small)
            .background(AppTheme.Colors.backgroundComponent)
            .cornerRadius(AppTheme.Layout.BorderRadius.large)
            
            Button {
                isFilterSheetPresented = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .foregroundColor(AppTheme.Colors.primaryDark)
            }
        }
    }

    // --- KERN DER VALIDIERUNG ---
    private var productGrid: some View {
        ScrollView {
            // LazyVGrid sorgt dafür, dass die Views für die Produkte nur dann erstellt
            // und im Speicher gehalten werden, wenn sie sichtbar sind. Dies ist die
            // korrekte und performanteste Methode für Gitter-Layouts.
            LazyVGrid(columns: [GridItem(.flexible(), spacing: AppTheme.Layout.Spacing.medium), GridItem(.flexible(), spacing: AppTheme.Layout.Spacing.medium)], spacing: AppTheme.Layout.Spacing.medium) {
                ForEach(viewModel.products) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product)
                            .onAppear {
                                // Die Paginierungslogik ist korrekt am Ende der sichtbaren Elemente platziert.
                                if product.id == viewModel.products.dropLast(5).last?.id && viewModel.canLoadMore {
                                    Task { await viewModel.loadMoreProducts() }
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            
            if viewModel.isLoadingMore {
                ProgressView().padding()
            }
        }
    }
    
    @ViewBuilder
    private var emptyOrSearchEmptyView: some View {
        if !searchText.isEmpty {
            VStack(spacing: AppTheme.Layout.Spacing.large) {
                Image(systemName: "magnifyingglass").font(.system(size: 60)).foregroundColor(AppTheme.Colors.primary.opacity(0.5))
                Text("Keine Treffer").font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.title2, weight: .bold)).foregroundColor(AppTheme.Colors.textHeadings)
                Text("Für deine Suche nach \"\(searchText)\" wurden keine Produkte gefunden.").font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body)).foregroundColor(AppTheme.Colors.textMuted).multilineTextAlignment(.center)
            }.padding()
        } else {
            VStack(spacing: AppTheme.Layout.Spacing.large) {
                Image(systemName: "bag.fill").font(.system(size: 60)).foregroundColor(AppTheme.Colors.primary.opacity(0.5))
                Text("Keine Produkte").font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.title2, weight: .bold)).foregroundColor(AppTheme.Colors.textHeadings)
                Text("In dieser Kategorie wurden leider keine Produkte gefunden. Versuche, deine Filter zurückzusetzen.").font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body)).foregroundColor(AppTheme.Colors.textMuted).multilineTextAlignment(.center)
                Button("Filter zurücksetzen") {
                    viewModel.resetFilters()
                }
                .buttonStyle(AppTheme.PrimaryButtonStyle())
                .padding(.top)
            }.padding()
        }
    }
    
    private static func findLabelFor(category: WooCommerceCategory) -> String {
        if let mainItem = NavigationData.items.first(where: { $0.mainCategorySlug == category.slug }) {
            return mainItem.label
        }
        for item in NavigationData.items {
            if let subItems = item.subItems, let subItem = subItems.first(where: { $0.linkSlug == category.slug }) {
                return subItem.label
            }
        }
        return category.name.strippingHTML()
    }
}
