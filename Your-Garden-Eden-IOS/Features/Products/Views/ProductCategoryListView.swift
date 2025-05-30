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



