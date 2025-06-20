// DATEI: RelatedProductsView.swift
// PFAD: Features/Products/Views/Components/RelatedProductsView.swift
// VERSION: 2.0 (SYNCHRONISIERT FÜR OPERATION "DOPPEL-AGENT")
// ZWECK: Stellt eine einfach gehaltene, horizontal scrollbare Liste von Produkten dar.

import SwiftUI

struct RelatedProductsView: View {
    // Die Komponente benötigt nun einen Titel und akzeptiert direkt das Kern-Modell.
    let title: String
    let products: [WooCommerceProduct]

    var body: some View {
        // Die Sektion wird nur angezeigt, wenn Produkte vorhanden sind.
        if !products.isEmpty {
            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.medium) {
                // Sektions-Titel wird nur angezeigt, wenn er nicht leer ist.
                if !title.isEmpty {
                    Text(title)
                        .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h6, weight: .semibold))
                        .padding(.horizontal)
                }

                // Einfache, horizontal scrollbare Liste.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Layout.Spacing.medium) {
                        // Iteriert direkt über die übergebenen Produkte.
                        ForEach(products) { product in
                            // Navigation zur Detailansicht des jeweiligen Produkts.
                            NavigationLink(value: product) {
                                ProductCardView(product: product)
                                    .frame(width: 160) // Feste Breite für konsistentes Layout.
                            }
                            .buttonStyle(.plain) // Standard-Button-Styling entfernen.
                        }
                    }
                    .padding(.horizontal) // Padding für die innere Liste.
                }
            }
            .padding(.vertical) // Vertikaler Abstand für die gesamte Sektion.
        }
    }
}
