// Dateiname: HomeView.swift

import SwiftUI
import AVKit

struct HomeView: View {
    // Greift auf die globalen, zentralen Daten-Manager zu
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var productViewModel: ProductViewModel

    // Lokaler Zustand NUR für die View-spezifische Logik (Videoplayer)
    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?
    @State private var queuePlayer: AVQueuePlayer?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                videoBannerSection
                categoryCarouselSection
                bestsellerSection
                FooterView().padding(.top, AppStyles.Spacing.large)
            }
        }
        .background(AppColors.backgroundPage.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo_your_garden_eden_transparent")
                    .resizable().aspectRatio(contentMode: .fit).frame(height: 70)
            }
        }
        .onAppear {
            // KEIN DATENLADEN MEHR HIER! DER ZYKLUS IST DURCHBROCHEN.
            if player == nil { initializePlayer() }
        }
    }

    // MARK: - Subviews
    
    @ViewBuilder
    private var videoBannerSection: some View {
        if let videoPlayer = player {
            VideoPlayer(player: videoPlayer)
                .frame(height: 200)
                .disabled(true)
                .background(AppColors.backgroundPage)
                .onAppear { videoPlayer.play() }
        } else {
            Rectangle()
                .fill(AppColors.backgroundPage)
                .frame(height: 200)
        }
    }

    @ViewBuilder
    private var categoryCarouselSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Unsere Kategorien")
                .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .semibold))
                .padding(.horizontal)

            if categoryViewModel.isLoading {
                ProgressView().frame(height: 120, alignment: .center)
            } else if let errorMessage = categoryViewModel.errorMessage {
                ErrorStateView(message: errorMessage)
            } else if !categoryViewModel.displayableCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(categoryViewModel.displayableCategories) { category in
                            NavigationLink(value: category) {
                                CategoryCarouselItemView(category: category)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    @ViewBuilder
    private var bestsellerSection: some View {
        if productViewModel.isLoadingBestsellers {
            ProgressView().frame(height: 200, alignment: .center)
        } else if let errorMessage = productViewModel.bestsellerErrorMessage {
            ErrorStateView(message: errorMessage)
        } else if !productViewModel.bestsellerProducts.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Bestseller")
                    .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .semibold))
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppStyles.Spacing.medium) {
                        ForEach(productViewModel.bestsellerProducts) { product in
                            NavigationLink(value: product) {
                                ProductCardView(product: product)
                                    .frame(width: 160)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Private Helper Functions

    private func initializePlayer() {
        guard let videoURL = Bundle.main.url(forResource: "hero_main_banner_yge", withExtension: "mp4") else {
            print("🔴 FEHLER: Videodatei 'hero_main_banner_yge.mp4' nicht im Bundle gefunden.")
            return
        }
        let playerItem = AVPlayerItem(url: videoURL)
        
        self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
        if let queuePlayer = self.queuePlayer {
            self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            queuePlayer.isMuted = true
            self.player = queuePlayer
        }
    }
}


// MARK: - Private Subviews (Gehören zur HomeView)

private struct CategoryCarouselItemView: View {
    let category: DisplayableMainCategory
    var body: some View {
        VStack(spacing: 8) {
            if let imageName = category.appItem.imageFilename {
                Image(imageName).resizable().scaledToFill().frame(width: 80, height: 80).clipShape(Circle())
            } else {
                ZStack {
                    Circle().fill(Color.gray.opacity(0.1))
                    Image(systemName: "photo.fill").resizable().scaledToFit().foregroundColor(Color.gray.opacity(0.4)).padding(20)
                }.frame(width: 80, height: 80)
            }
            Text(category.appItem.label).font(AppFonts.montserrat(size: AppFonts.Size.caption, weight: .semibold)).foregroundColor(AppColors.textBase).frame(width: 90).multilineTextAlignment(.center).lineLimit(2)
        }.overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1).frame(width: 80, height: 80).offset(y: -22)).shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

private struct ErrorStateView: View {
    let message: String
    var body: some View {
        Text(message).font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular)).foregroundColor(AppColors.error).padding().frame(maxWidth: .infinity, alignment: .center).multilineTextAlignment(.center)
    }
}
