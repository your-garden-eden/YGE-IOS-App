// Path: Your-Garden-Eden-IOS/Features/Home/HomeView.swift

import SwiftUI
import AVKit

struct HomeView: View {
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var productViewModel: ProductViewModel

    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?
    @State private var queuePlayer: AVQueuePlayer?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppStyles.Spacing.xxLarge) {
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
                .background(AppColors.backgroundLightGray)
                .onAppear { videoPlayer.play() }
                .onDisappear { videoPlayer.pause() }
        } else {
            Rectangle()
                .fill(AppColors.backgroundLightGray)
                .frame(height: 200)
                .overlay(ProgressView())
        }
    }

    @ViewBuilder
    private var categoryCarouselSection: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
            Text("Unsere Kategorien")
                .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .semibold))
                .padding(.horizontal)

            if categoryViewModel.isLoading && categoryViewModel.displayableCategories.isEmpty {
                ProgressView().frame(maxWidth: .infinity, minHeight: 120)
            } else if let errorMessage = categoryViewModel.errorMessage {
                ErrorStateView(message: errorMessage)
            } else if !categoryViewModel.displayableCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: AppStyles.Spacing.large) {
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
        if productViewModel.isLoadingBestsellers && productViewModel.bestsellerProducts.isEmpty {
            ProgressView().frame(maxWidth: .infinity, minHeight: 200)
        } else if let errorMessage = productViewModel.bestsellerErrorMessage {
            ErrorStateView(message: errorMessage)
        } else if !productViewModel.bestsellerProducts.isEmpty {
            VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
                Text("Bestseller")
                    .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .semibold))
                    .padding(.horizontal)
                
                RelatedProductsView(products: productViewModel.bestsellerProducts.map { IdentifiableDisplayProduct(product: $0) })
            }
        }
    }
    
    // MARK: - Private Helper Functions

    private func initializePlayer() {
        guard let videoURL = Bundle.main.url(forResource: "hero_main_banner_yge", withExtension: "mp4") else {
            print("🔴 ERROR: Video file 'hero_main_banner_yge.mp4' not found in Bundle.")
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


// MARK: - Private Subviews for HomeView
private struct CategoryCarouselItemView: View {
    let category: DisplayableMainCategory
    
    var body: some View {
        VStack(spacing: AppStyles.Spacing.small) {
            if let imageName = category.appItem.imageFilename {
                Image(imageName)
                    .resizable().scaledToFill().frame(width: 80, height: 80).clipShape(Circle())
            } else {
                ZStack {
                    Circle().fill(AppColors.backgroundLightGray)
                    Image(systemName: "photo.fill").resizable().scaledToFit().foregroundColor(AppColors.textMuted.opacity(0.4)).padding(20)
                }.frame(width: 80, height: 80)
            }
            Text(category.appItem.label)
                .font(AppFonts.montserrat(size: AppFonts.Size.caption, weight: .semibold))
                .foregroundColor(AppColors.textBase)
                .frame(width: 90)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1).frame(width: 80, height: 80).offset(y: -22))
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

