// DATEI: ShopView.swift
// PFAD: Features/Categories/Views/ShopView.swift
// ZWECK: Die Hauptansicht des "Shop"-Tabs, die eine Liste aller Top-Level-Kategorien anzeigt.
//        Sie dient als primärer visueller Einstiegspunkt in die Shop-Struktur.

import SwiftUI

struct ShopView: View {
    // Greift auf das `HomeViewModel` zu, das bereits beim App-Start initialisiert
    // und mit den Top-Level-Kategorien befüllt wird. Dies verhindert redundante API-Aufrufe.
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundPage.ignoresSafeArea()

            if viewModel.isLoadingCategories {
                ProgressView().tint(AppTheme.Colors.primary)
            } else if let errorMessage = viewModel.categoryErrorMessage {
                StatusIndicatorView.errorState(message: errorMessage)
            } else {
                // Die Haupt-Scroll-Ansicht, die die Kategorieliste enthält.
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.large) {
                        ForEach(viewModel.topLevelCategories) { category in
                            let displayName = viewModel.getDisplayName(for: category)
                            
                            // Jede Kategorie wird als eigene Sektion mit Titel und klickbarer Karte dargestellt.
                            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.medium) {
                                Text(displayName)
                                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h3, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.textHeadings)
                                
                                NavigationLink(value: category) {
                                    // Nutzt die neue, überlegene `CategoryCardView` Komponente im Stil `.imageOnly`,
                                    // da der Titel bereits separat darüber steht.
                                    CategoryCardView(category: category, style: .imageOnly)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            // Stellt sicher, dass die Daten geladen werden, falls die View
            // aufgerufen wird, bevor die HomeView die Daten geladen hat.
            if viewModel.topLevelCategories.isEmpty {
                await viewModel.loadInitialData()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo_your_garden_eden_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            }
        }
    }
}
