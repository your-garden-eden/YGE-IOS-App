//
//  ProductListView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//


// YGE-IOS-App/Features/Products/Views/ProductListView.swift

import SwiftUI

struct ProductListView: View {
    let categoryId: Int
    let categoryName: String

    @StateObject private var viewModel = ProductListViewModel()

    var body: some View {
        Group { // Group verwenden, um Conditional Content zu managen
            if viewModel.isLoading && viewModel.products.isEmpty { // Nur initialer Ladezustand
                ProgressView {
                    Text("Lade Produkte...")
                        .font(AppFonts.roboto(size: AppFonts.Size.body))
                        .foregroundColor(AppColors.textMuted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.backgroundPage.ignoresSafeArea())
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: AppStyles.Spacing.medium) {
                    Image(systemName: "exclamationmark.server.fill") // Anderes Icon für Serverfehler
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.error)
                    Text("Fehler beim Laden")
                        .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .semibold))
                        .foregroundColor(AppColors.textHeadings)
                    Text(errorMessage)
                        .font(AppFonts.roboto(size: AppFonts.Size.body))
                        .foregroundColor(AppColors.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppStyles.Spacing.medium)
                    Button("Erneut versuchen") {
                        viewModel.fetchProducts(categoryId: categoryId, initialLoad: true)
                    }
                    .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .medium))
                    .padding(.horizontal, AppStyles.Spacing.large)
                    .padding(.vertical, AppStyles.Spacing.small)
                    .foregroundColor(AppColors.textOnPrimary)
                    .background(AppColors.primary)
                    .cornerRadius(AppStyles.BorderRadius.medium)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(AppStyles.Spacing.large)
                .background(AppColors.backgroundPage.ignoresSafeArea())
            } else if viewModel.products.isEmpty {
                VStack(spacing: AppStyles.Spacing.medium) {
                    Image(systemName: "basket.fill") // Icon für leeren Warenkorb/Produktliste
                         .font(.system(size: 50))
                         .foregroundColor(AppColors.textMuted)
                    Text("Keine Produkte")
                        .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .semibold))
                        .foregroundColor(AppColors.textHeadings)
                    Text("In der Kategorie \"\(categoryName)\" wurden keine Produkte gefunden.")
                        .font(AppFonts.roboto(size: AppFonts.Size.body))
                        .foregroundColor(AppColors.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppStyles.Spacing.medium)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(AppStyles.Spacing.large)
                .background(AppColors.backgroundPage.ignoresSafeArea())
            } else {
                List {
                    ForEach(viewModel.products) { product in
                        ZStack { // ZStack ermöglicht es, den NavigationLink unsichtbar über die ganze Zelle zu legen
                            NavigationLink(value: product) { EmptyView() }.opacity(0) // Unsichtbarer Link
                            ProductRowView(product: product)
                        }
                        .listRowInsets(EdgeInsets( // Einheitliches Padding für Zellen
                            top: AppStyles.Spacing.small,
                            leading: AppStyles.Spacing.medium,
                            bottom: AppStyles.Spacing.small,
                            trailing: AppStyles.Spacing.medium
                        ))
                        .listRowBackground(AppColors.backgroundComponent) // Hintergrund für jede Zelle
                        .listRowSeparator(.hidden) // Eigene Separatoren oder keine
                        .onAppear {
                            viewModel.loadMoreContentIfNeeded(currentItem: product)
                        }
                    }

                    if viewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView {
                                Text("Mehr laden...")
                                    .font(AppFonts.roboto(size: AppFonts.Size.caption))
                                    .foregroundColor(AppColors.textMuted)
                            }
                            .tint(AppColors.primary)
                            Spacer()
                        }
                        .listRowBackground(Color.clear) // Kein Hintergrund für die Ladezelle
                        .padding(.vertical, AppStyles.Spacing.medium)
                    }
                }
                .listStyle(.plain) // .plain für volle Kontrolle über Row-Styling
                .background(AppColors.backgroundPage) // Hintergrund für die Liste
                .scrollContentBackground(.hidden) // iOS 16+, um Standard-Listenhintergrund zu entfernen
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.large) // Großer Titel für Kategorieseiten
        .toolbarBackground(AppColors.backgroundPage.opacity(0.8), for: .navigationBar) // Konsistente Toolbar
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationDestination(for: WooCommerceProduct.self) { product in
             ProductDetailView(productSlug: product.slug, initialProductData: product) // initialProductData übergeben
        }
        .onAppear {
            if viewModel.currentCategoryId != categoryId || (viewModel.products.isEmpty && !viewModel.isLoading && !viewModel.isLoadingMore) {
                viewModel.fetchProducts(categoryId: categoryId, initialLoad: true)
            }
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { // ProductListView wird normalerweise in einer NavigationStack angezeigt
            ProductListView(categoryId: 1, categoryName: "Beispiel Kategorie")
        }
    }
}