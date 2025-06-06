import SwiftUI
import AVKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    private let heroVideoNameInBundle = "hero_main_banner_yge"
    private let videoFileExtension = "mp4"

    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?
    @State private var queuePlayer: AVQueuePlayer?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 1. Hero Banner als Video
                    if let videoPlayer = player {
                        VideoPlayer(player: videoPlayer)
                            .frame(height: 200)
                            .disabled(true)
                            // KORREKTUR 1: Hintergrundfarbe setzen, um Schwarz zu vermeiden
                            .background(AppColors.backgroundPage)
                            .onAppear {
                                videoPlayer.play()
                            }
                    } else {
                        // Dieser Fallback wird jetzt angezeigt, während der Player initialisiert.
                        // Er hat dieselbe Hintergrundfarbe wie das Video, daher kein "Blitz".
                        AppColors.backgroundPage
                            .frame(height: 0)
                    }
                    
                    // 2. Bestseller Produkte Sektion
                    if !viewModel.bestsellerProducts.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Bestseller")
                                .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .semibold))
                                .padding([.top, .horizontal])
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppStyles.Spacing.medium) {
                                    ForEach(viewModel.bestsellerProducts) { product in
                                        NavigationLink(value: product) {
                                            ProductCardView(product: product)
                                                .frame(width: 160)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal).padding(.bottom)
                            }
                        }.padding(.top)
                    } else if viewModel.isLoading {
                        ProgressView("Lade Bestseller...").padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text("Fehler: \(errorMessage)").foregroundColor(AppColors.error).padding()
                    }

                    // KORREKTUR 2: Der Platzhalter-Inhalt wurde entfernt.
                    // Die Zeile ForEach(0..<5) ... wurde gelöscht.
                    
                    // Footer am Ende
                    Spacer(minLength: AppStyles.Spacing.large)
                    FooterView()
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
            .navigationDestination(for: WooCommerceProduct.self) { product in
                ProductDetailView(productSlug: product.slug, initialProductData: product)
            }
            .onAppear {
                if player == nil {
                    initializePlayer()
                }
                if viewModel.bestsellerProducts.isEmpty && !viewModel.isLoading {
                    viewModel.loadDataForHomeView()
                }
            }
        }
    }

    private func initializePlayer() {
        guard let videoURL = Bundle.main.url(forResource: heroVideoNameInBundle, withExtension: videoFileExtension) else {
            print("HomeView ERROR: Video '\(heroVideoNameInBundle).\(videoFileExtension)' not found.")
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
