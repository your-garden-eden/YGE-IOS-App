//
//  OrderListViewModel.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.06.25.
//


// DATEI: OrderListView.swift
// PFAD: Features/Profile/Views/OrderListView.swift
// VERSION: STAMMDATEN 1.0
// STATUS: NEU

import SwiftUI

@MainActor
class OrderListViewModel: ObservableObject {
    @Published var orders: [OrderSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let orderAPIManager = OrderAPIManager.shared

    func fetchOrders() async {
        isLoading = true
        errorMessage = nil
        do {
            orders = try await orderAPIManager.fetchOrders()
        } catch {
            errorMessage = "Ihre Bestellungen konnten nicht geladen werden. Bitte versuchen Sie es später erneut."
        }
        isLoading = false
    }
}

struct OrderListView: View {
    @StateObject private var viewModel = OrderListViewModel()

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundPage.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text(errorMessage)
                        .foregroundColor(AppTheme.Colors.error)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Erneut versuchen") {
                        Task { await viewModel.fetchOrders() }
                    }
                    .buttonStyle(AppTheme.PrimaryButtonStyle())
                    .padding()
                }
            } else if viewModel.orders.isEmpty {
                Text("Sie haben noch keine Bestellungen getätigt.")
                    .foregroundColor(AppTheme.Colors.textMuted)
            } else {
                List {
                    ForEach(viewModel.orders) { order in
                        NavigationLink(destination: OrderDetailView(orderSummary: order)) {
                            OrderRow(order: order)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Meine Bestellungen")
        .task {
            await viewModel.fetchOrders()
        }
    }
}

struct OrderRow: View {
    let order: OrderSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Bestellung #\(order.orderNumber)")
                    .font(AppTheme.Fonts.roboto(size: 16, weight: .bold))
                Spacer()
                Text("\(order.totalPrice) \(order.currency)")
                    .font(AppTheme.Fonts.roboto(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primary)
            }
            Text(order.orderDate, style: .date)
                .font(AppTheme.Fonts.roboto(size: 14))
                .foregroundColor(AppTheme.Colors.textMuted)
            Text("Status: \(order.status)")
                .font(AppTheme.Fonts.roboto(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.textMuted)
        }
        .padding(.vertical, 8)
    }
}