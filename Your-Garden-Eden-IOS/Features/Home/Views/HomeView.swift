import SwiftUI
import AVKit

struct HomeView: View {
    @EnvironmentObject private var productViewModel: ProductViewModel
    @EnvironmentObject private var categoryViewModel: CategoryViewModel
    
    @State private var player: AVPlayer?
    @State private var playerObserver: Any?

    var body: some View {
        ScrollView {
            // Der VStack hat keinen Top-Padding mehr, damit das Banner bündig abschließt.
            // Der Abstand zum nächsten Element wird durch 'spacing' geregelt.
            VStack(alignment: .leading, spacing: AppStyles.Spacing.xLarge) {
                heroBannerVideo
                    // --- ÄNDERUNG START ---
                    // 1. Höhe für mehr visuelle Präsenz erhöht.
                    // 2. Explizit auf maximale Breite gesetzt, um die volle Ausdehnung sicherzustellen.
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    // --- ÄNDERUNG ENDE ---
                
                // 2. Kategorien Sektion
                Section {
                    Text("Kategorien entdecken")
                        .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .bold))
                        .padding(.horizontal)
                    
                    if categoryViewModel.isLoading {
                        ProgressView().frame(maxWidth: .infinity, minHeight: 150)
                    } else if let errorMessage = categoryViewModel.errorMessage {
                         ErrorStateView(message: errorMessage).padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppStyles.Spacing.medium) {
                                ForEach(categoryViewModel.topLevelCategories) { category in
                                    NavigationLink(value: category) {
                                        CategoryCarouselItemView(
                                            category: category,
                                            displayName: findLabelFor(category: category)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                        }
                    }
                }
                
                // 3. Bestseller Sektion
                Section {
                    Text("Bestseller")
                        .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .bold))
                        .padding(.horizontal)
                    
                    if productViewModel.isLoadingBestsellers {
                        ProgressView().frame(maxWidth: .infinity, minHeight: 150)
                    } else if let errorMessage = productViewModel.bestsellerErrorMessage {
                        ErrorStateView(message: errorMessage).padding()
                    } else {
                        RelatedProductsView(products: productViewModel.bestsellerProducts.map { IdentifiableDisplayProduct(product: $0) })
                    }
                }
                
                // 4. Footer
                FooterView()
            }
            // --- ÄNDERUNG: Das Padding wurde von hier entfernt. ---
            // .padding(.top, AppStyles.Spacing.large)
        }
        .background(AppColors.backgroundPage.ignoresSafeArea())
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
    }
    
    // MARK: - Subviews & Helper
    
    @ViewBuilder
    private var heroBannerVideo: some View {
        if let player = player { VideoPlayer(player: player).disabled(true) }
        else { ZStack { AppColors.backgroundLightGray; Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppColors.textMuted.opacity(0.3)) } }
    }
    
    private func findLabelFor(category: WooCommerceCategory) -> String {
        return AppNavigationData.items.first { $0.mainCategorySlug == category.slug }?.label ?? category.name.strippingHTML()
    }

    private func setupPlayer() {
        guard player == nil else { return }
        guard let fileURL = Bundle.main.url(forResource: "hero_main_banner_yge", withExtension: "mp4") else { print("🔴 Video Error: hero_main_banner_yge.mp4 not found in bundle."); return }
        let playerItem = AVPlayerItem(url: fileURL)
        let avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer.isMuted = true
        self.playerObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in avPlayer.seek(to: .zero); avPlayer.play() }
        self.player = avPlayer; avPlayer.play()
    }
    
    private func cleanupPlayer() {
        player?.pause();
        if let observer = playerObserver { NotificationCenter.default.removeObserver(observer); playerObserver = nil }
        player = nil
    }
}
