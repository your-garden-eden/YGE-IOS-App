// DATEI: HomeView.swift
// PFAD: Features/Home/Views/HomeView.swift
// VERSION: 2.2 (VOLLSTÄNDIG & FEHLER BEHOBEN)
// ZWECK: Die Hauptansicht der App, die als Einstiegspunkt dient und verschiedene
//        Sektionen wie Kategorien und Bestseller präsentiert.

import SwiftUI
import AVKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var player: AVPlayer?
    @State private var playerObserver: Any?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.xLarge) {
                heroBannerVideo
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                
                categoriesSection
                
                bestsellerSection
                
                FooterView()
            }
        }
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo_your_garden_eden_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            }
        }
        .onAppear(perform: setupPlayer)
        .onDisappear(perform: cleanupPlayer)
        .task {
            // Lädt alle Daten, wenn die View zum ersten Mal erscheint.
            await viewModel.loadInitialData()
        }
    }
    
    // MARK: - Subviews
    
    /// Die Sektion, die das Hero-Video anzeigt.
    private var heroBannerVideo: some View {
        VideoPlayerView(player: $player)
            .onAppear(perform: { player?.play() })
            .onDisappear(perform: { player?.pause() })
    }
    
    /// Die Sektion, die das horizontale Karussell der Top-Level-Kategorien anzeigt.
    private var categoriesSection: some View {
        Section {
            Text("Kategorien entdecken")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h3, weight: .bold))
                .padding(.horizontal)
            
            if viewModel.isLoadingCategories {
                ProgressView().frame(maxWidth: .infinity, minHeight: 150)
            } else if let errorMessage = viewModel.categoryErrorMessage {
                // KORREKTUR: Nutzt die neue, überlegene Status-Komponente.
                StatusIndicatorView.errorState(message: errorMessage)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Layout.Spacing.medium) {
                        ForEach(viewModel.topLevelCategories) { category in
                            NavigationLink(value: category) {
                                // Diese Komponente wurde bereits in einer früheren Operation zentralisiert.
                                CategoryCarouselItemView(
                                    category: category,
                                    displayName: viewModel.getDisplayName(for: category)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    /// Die Sektion, die die Bestseller-Produkte in einer horizontalen Liste anzeigt.
    private var bestsellerSection: some View {
        Section {
            Text("Bestseller")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h3, weight: .bold))
                .padding(.horizontal)
            
            if viewModel.isLoadingBestsellers {
                ProgressView().frame(maxWidth: .infinity, minHeight: 150)
            } else if let errorMessage = viewModel.bestsellerErrorMessage {
                // KORREKTUR: Nutzt die neue, überlegene Status-Komponente.
                StatusIndicatorView.errorState(message: errorMessage)
                    .padding()
            } else {
                RelatedProductsView(products: viewModel.bestsellerProducts.map { .init(product: $0) })
            }
        }
    }

    // MARK: - Player Logic
    
    /// Initialisiert den AVPlayer sicher im Hintergrund, um den Main-Thread nicht zu blockieren.
    private func setupPlayer() {
        guard player == nil else {
            player?.play() // Spielt das Video ab, wenn man zur View zurückkehrt.
            return
        }

        Task(priority: .background) {
            guard let fileURL = Bundle.main.url(forResource: "hero_main_banner_yge", withExtension: "mp4") else {
                print("🔴 Video Error: hero_main_banner_yge.mp4 not found in bundle.")
                return
            }
            
            let playerItem = AVPlayerItem(url: fileURL)
            let avPlayer = AVPlayer(playerItem: playerItem)
            avPlayer.isMuted = true

            // UI-Updates (Zuweisung zum @State) und Observer müssen auf dem Main-Thread erfolgen.
            await MainActor.run {
                self.playerObserver = NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main
                ) { _ in
                    avPlayer.seek(to: .zero)
                    avPlayer.play()
                }
                self.player = avPlayer
                avPlayer.play()
            }
        }
    }
    
    /// Räumt die Player-Ressourcen auf, wenn die View verlassen wird.
    private func cleanupPlayer() {
        player?.pause()
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
            playerObserver = nil
        }
        // Der Player wird nicht auf `nil` gesetzt, um den Zustand bei schneller Rückkehr zur View zu erhalten.
    }
}

/// Eine gekapselte, private View, die den AVPlayer sicher handhabt und einen Platzhalter anzeigt.
private struct VideoPlayerView: View {
    @Binding var player: AVPlayer?
    
    var body: some View {
        if let player = player {
            VideoPlayer(player: player)
                .disabled(true) // Verhindert, dass der Benutzer die Wiedergabe steuert.
        }
        else {
            // Platzhalter, während das Video im Hintergrund geladen wird.
            ZStack {
                AppTheme.Colors.backgroundLightGray
                Image(systemName: "photo.fill")
                    .font(.largeTitle)
                    .foregroundColor(AppTheme.Colors.textMuted.opacity(0.3))
            }
        }
    }
}


