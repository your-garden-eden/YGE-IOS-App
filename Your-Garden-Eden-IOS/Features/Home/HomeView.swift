// DATEI: HomeView.swift
// PFAD: Features/Home/Views/HomeView.swift
// VERSION: 2.7 (FINAL)

import SwiftUI
import AVKit

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    @State private var player: AVPlayer?
    @State private var playerObserver: Any?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.xLarge) {
                heroBannerVideo
                    .frame(height: 220)
                
                categoriesSection
                
                bestsellerSection
                
                FooterView()
            }
        }
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo_your_garden_eden_transparent")
                    .resizable().scaledToFit().frame(height: 150)
            }
        }
        .onAppear(perform: setupPlayer)
        .onDisappear(perform: cleanupPlayer)
    }
    
    private var heroBannerVideo: some View {
        VideoPlayerView(player: $player)
            .onAppear(perform: { player?.play() })
            .onDisappear(perform: { player?.pause() })
    }
    
    private var categoriesSection: some View {
        Section {
            Text("Kategorien entdecken")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h3, weight: .bold))
                .padding(.horizontal)
            
            if viewModel.isLoadingCategories {
                ProgressView().frame(maxWidth: .infinity, minHeight: 150)
            } else if let errorMessage = viewModel.categoryErrorMessage {
                StatusIndicatorView.errorState(message: errorMessage).padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: AppTheme.Layout.Spacing.medium) {
                        ForEach(viewModel.topLevelCategories) { category in
                            NavigationLink(value: category) {
                                VStack(spacing: AppTheme.Layout.Spacing.small) {
                                    Text(viewModel.getDisplayName(for: category))
                                        .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.body, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.textHeadings)
                                        .frame(width: 240, height: 40, alignment: .leading)
                                        .lineLimit(2)

                                    CategoryCardView(category: category, style: .imageOnly)
                                        .frame(width: 240, height: 135)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    @ViewBuilder
    private var bestsellerSection: some View {
        Section {
            Text("Bestseller")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h3, weight: .bold))
                .padding(.horizontal)
            
            if viewModel.isLoadingBestsellers {
                ProgressView().frame(maxWidth: .infinity, minHeight: 150)
            } else if let errorMessage = viewModel.bestsellerErrorMessage {
                StatusIndicatorView.errorState(message: errorMessage).padding()
            } else {
                RelatedProductsView(title: "", products: viewModel.bestsellerProducts)
            }
        }
    }

    private func setupPlayer() {
        guard player == nil else { player?.play(); return }
        Task(priority: .background) {
            guard let url = Bundle.main.url(forResource: "hero_main_banner_yge", withExtension: "mp4") else { return }
            let item = AVPlayerItem(url: url)
            let avPlayer = AVPlayer(playerItem: item)
            avPlayer.isMuted = true
            await MainActor.run {
                self.playerObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { _ in
                    avPlayer.seek(to: .zero); avPlayer.play()
                }
                self.player = avPlayer; avPlayer.play()
            }
        }
    }
    
    private func cleanupPlayer() {
        player?.pause()
        if let observer = playerObserver { NotificationCenter.default.removeObserver(observer); playerObserver = nil }
    }
}

private struct VideoPlayerView: View {
    @Binding var player: AVPlayer?
    
    var body: some View {
        if let player = player { VideoPlayer(player: player).disabled(true) }
        else { ZStack { AppTheme.Colors.backgroundLightGray; ShimmerView() } }
    }
}
