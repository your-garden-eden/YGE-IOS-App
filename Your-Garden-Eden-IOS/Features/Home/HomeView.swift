// Features/Home/Views/HomeView.swift
import SwiftUI
import AVKit

@available(iOS 17.0, *)
struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State private var player: AVPlayer?
    @State private var currentBestsellerScrollID: Int?
    @State private var activeScrollIDForLogic: Int?
    @State private var hasScrolledInitially = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // HIER WIRD heroVideoView() AUFGERUFEN - DAS IST KORREKT
                    heroVideoView()
                        .frame(height: 220) // Höhe, wie zuletzt besprochen
                        .padding(.bottom, AppStyles.Spacing.large)
                    
                    bestsellerProductsSection()
                        .padding(.bottom, AppStyles.Spacing.large)
                    
                    Spacer()
                }
            }
            // ... (Rest der View: .background, .navigationBarTitleDisplayMode, .toolbar etc. bleiben gleich) ...
            .background(AppColors.backgroundPage.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundComponent.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("logo_your_garden_eden_transparent")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                }
            }
            .onAppear {
                if viewModel.bestsellerProducts.isEmpty && !viewModel.isLoading {
                    viewModel.loadDataForHomeView()
                }
                setupVideoPlayer()
                 // Logik für initialen Scroll der Bestseller (iOS 17+)
                if !viewModel.bestsellerProducts.isEmpty && !hasScrolledInitially && viewModel.bestsellerProducts.count > 0 {
                    let initialTargetID = viewModel.bestsellerProducts.count // Start des mittleren Satzes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Etwas mehr Verzögerung
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            self.currentBestsellerScrollID = initialTargetID
                        }
                        self.hasScrolledInitially = true
                        print("Loop iOS 17: Initial onAppear scroll to ID \(initialTargetID)")
                    }
                }
            }
            .onDisappear {
                player?.pause()
                if let playerItem = player?.currentItem {
                    NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
                }
            }
        }
    }
    
    // setupVideoPlayer() Methode (bleibt unverändert von deinem letzten Stand)
    private func setupVideoPlayer() {
        guard let videoURL = Bundle.main.url(forResource: "hero_main_banner_yge", withExtension: "mp4") else {
            print("HomeView Error: Video hero_main_banner_yge.mp4 not found in bundle.")
            return
        }
        let playerItem = AVPlayerItem(url: videoURL)
        let avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer.isMuted = true
        avPlayer.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak avPlayer] _ in
            avPlayer?.seek(to: CMTime.zero)
            avPlayer?.play()
        }
        self.player = avPlayer
        self.player?.play()
    }

    // heroVideoView() Methode (bleibt unverändert von deinem letzten Stand, ohne Text-Overlay)
    @ViewBuilder
    private func heroVideoView() -> some View {
        ZStack { // .bottomLeading ist nicht mehr nötig, da kein Text-Overlay
            if let player = player {
                VideoPlayer(player: player)
                    .disabled(true)
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 220)
                    .clipped()
            } else {
                Rectangle()
                    .fill(AppColors.backgroundLightGray)
                    .frame(height: 220)
                    .overlay(
                        VStack {
                            Image(systemName: "film.fill")
                                .font(.largeTitle)
                                .foregroundColor(AppColors.textMuted)
                            Text("Video wird vorbereitet...")
                                .font(AppFonts.roboto(size: AppFonts.Size.caption))
                                .foregroundColor(AppColors.textMuted)
                        }
                    )
            }
        }
    }

    // bestsellerProductsSection() Methode (bleibt unverändert von deinem letzten Stand mit iOS 17 Loop)
    @ViewBuilder
    private func bestsellerProductsSection() -> some View {
        // ... (dein Code für die Bestseller-Sektion mit iOS 17 Loop)
        let products = viewModel.bestsellerProducts
        let cardWidth: CGFloat = 170
        let spacing: CGFloat = AppStyles.Spacing.medium
        let totalItemsInOriginalSet = products.count
        let totalDisplayedItems = totalItemsInOriginalSet * 3

        VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
            Text("Unsere Bestseller")
                .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
                .padding(.horizontal, AppStyles.Spacing.medium)

            if viewModel.isLoading && products.isEmpty {
                HStack { Spacer(); ProgressView().padding(); Spacer() }
            } else if let errorMessage = viewModel.errorMessage, products.isEmpty {
                Text(errorMessage).foregroundColor(.red).padding(.horizontal, AppStyles.Spacing.medium)
            } else if products.isEmpty && !viewModel.isLoading {
                Text("Momentan sind keine Bestseller verfügbar.").foregroundColor(AppColors.textMuted).padding(.horizontal, AppStyles.Spacing.medium)
            } else if !products.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(0..<totalDisplayedItems, id: \.self) { displayIndex in
                            let productIndexInOriginalSet = displayIndex % totalItemsInOriginalSet
                            let product = products[productIndexInOriginalSet]
                            
                            NavigationLink(value: product) {
                                ProductCardView(product: product) // Hier wird die geänderte ProductCardView verwendet
                                    .frame(width: cardWidth)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .id(displayIndex)
                        }
                    }
                    .padding(.horizontal, AppStyles.Spacing.medium)
                    .padding(.vertical, AppStyles.Spacing.small)
                }
                .scrollPosition(id: $currentBestsellerScrollID)
                .onChange(of: currentBestsellerScrollID) { oldValue, newValue in
                    guard let newID = newValue, totalItemsInOriginalSet > 0 else { return }
                    if newID == activeScrollIDForLogic { activeScrollIDForLogic = nil; return }
                    let middleSetStartIndex = totalItemsInOriginalSet
                    let middleSetEndIndex = totalItemsInOriginalSet * 2 - 1
                    if newID < middleSetStartIndex {
                        let relativeIndexInClone = newID
                        let targetID = middleSetEndIndex - relativeIndexInClone
                        activeScrollIDForLogic = targetID; var t = Transaction(); t.disablesAnimations = true; withTransaction(t) { currentBestsellerScrollID = targetID }
                        print("Loop iOS 17 L: ID \(newID) -> \(targetID)")
                    } else if newID > middleSetEndIndex {
                        let relativeIndexInClone = newID - (totalItemsInOriginalSet * 2)
                        let targetID = middleSetStartIndex + relativeIndexInClone
                        activeScrollIDForLogic = targetID; var t = Transaction(); t.disablesAnimations = true; withTransaction(t) { currentBestsellerScrollID = targetID }
                        print("Loop iOS 17 R: ID \(newID) -> \(targetID)")
                    }
                }
                // .onAppear für initialen Scroll ist oben in der Haupt-View .onAppear, um sicherzustellen, dass viewModel.bestsellerProducts geladen ist
                .onChange(of: products.count) {
                    hasScrolledInitially = false
                    // Wenn Produkte neu geladen werden, und die aktuelle Scroll-ID außerhalb des neuen Bereichs liegt,
                    // oder wir einen sauberen Reset wollen:
                    if let currentID = currentBestsellerScrollID, currentID >= totalItemsInOriginalSet * 3 && totalItemsInOriginalSet > 0 {
                        currentBestsellerScrollID = totalItemsInOriginalSet // Reset zum Anfang des mittleren Satzes
                    } else if totalItemsInOriginalSet > 0 && !hasScrolledInitially { // Erneuter Versuch für initialen Scroll
                         let initialTargetID = totalItemsInOriginalSet
                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            var transaction = Transaction(); transaction.disablesAnimations = true
                            withTransaction(transaction) { self.currentBestsellerScrollID = initialTargetID }
                            self.hasScrolledInitially = true
                            print("Loop iOS 17 (products.count changed): Initial scroll to ID \(initialTargetID)")
                        }
                    }
                }
            }
        }
        .navigationDestination(for: WooCommerceProduct.self) { product in
            ProductDetailView(productSlug: product.slug, initialProductData: product)
        }
    }
}

// Preview Provider
@available(iOS 17.0, *)
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
