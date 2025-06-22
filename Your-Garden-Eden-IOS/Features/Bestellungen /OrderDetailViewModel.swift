//
//  OrderDetailViewModel.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.06.25.
//


// DATEI: OrderDetailView.swift
// PFAD: Features/Profile/Views/OrderDetailView.swift
// VERSION: STAMMDATEN 1.0
// STATUS: NEU

import SwiftUI

@MainActor
class OrderDetailViewModel: ObservableObject {
    @Published var orderDetail: OrderDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let orderAPIManager = OrderAPIManager.shared

    func fetchOrderDetail(id: String) async {
        isLoading = true
        errorMessage = nil
        do {
            orderDetail = try await orderAPIManager.fetchOrderDetail(id: id)
        } catch {
            errorMessage = "Die Bestelldetails konnten nicht geladen werden."
        }
        isLoading = false
    }
}

struct OrderDetailView: View {
    let orderSummary: OrderSummary
    @StateObject private var viewModel = OrderDetailViewModel()

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundPage.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(AppTheme.Colors.error)
            } else if let detail = viewModel.orderDetail {
                List {
                    Section(header: Text("Bestellübersicht")) {
                        InfoRow(label: "Bestellnummer", value: detail.orderNumber)
                        InfoRow(label: "Bestelldatum", value: detail.orderDate.formatted(date: .long, time: .shortened))
                        InfoRow(label: "Status", value: detail.status)
                        InfoRow(label: "Gesamtsumme", value: "\(detail.totalPrice) \(detail.currency)")
                    }
                    
                    Section(header: Text("Artikel")) {
                        ForEach(detail.lineItems) { item in
                            LineItemRow(item: item)
                        }
                    }
                    
                    Section(header: Text("Lieferadresse")) {
                        Text(formatAddress(detail.shippingAddress))
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Bestellung #\(orderSummary.orderNumber)")
        .task {
            await viewModel.fetchOrderDetail(id: orderSummary.id)
        }
    }
    
    private func formatAddress(_ address: OrderDetail.ShippingAddress) -> String {
        return """
        \(address.street)
        \(address.zipCode) \(address.city)
        \(address.country)
        """
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Fonts.roboto(size: 16))
            Spacer()
            Text(value)
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct LineItemRow: View {
    let item: OrderDetail.LineItem

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.productName)
                    .font(AppTheme.Fonts.roboto(size: 16, weight: .medium))
                Text("Menge: \(item.quantity)")
                    .font(AppTheme.Fonts.roboto(size: 14))
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
            Spacer()
            Text("\(item.price) €")
                .font(AppTheme.Fonts.roboto(size: 16))
        }
        .padding(.vertical, 4)
    }
}