// Features/Home/Views/HomeView.swift
import SwiftUI
import AVKit // Wichtig für AVPlayer und VideoPlayer

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    // Der Name der Videodatei im Projekt-Bundle (OHNE die Endung .mp4 hier, da sie in withExtension angegeben wird)
    private let heroVideoNameInBundle = "hero_main_banner_yge"
    private let videoFileExtension = "mp4"

    // State für den AVPlayer, damit er nur einmal erstellt wird
    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper? // Für den Loop
    @State private var queuePlayer: AVQueuePlayer? // Für den Loop mit AVPlayerLooper

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 1. Hero Banner als Video
                    if let videoPlayer = player { // Verwende den @State player
                        VideoPlayer(player: videoPlayer)
                            .frame(height: 300) // Höhe des Banners festlegen
                            .disabled(true) // Deaktiviert Benutzerinteraktion mit den Video-Controls
                            .onAppear {
                                print("HomeView: VideoPlayer appeared. Playing video.")
                                videoPlayer.play()
                            }
                            .onDisappear {
                                print("HomeView: VideoPlayer disappeared. Pausing video.")
                                // Optional: Video pausieren, wenn die View verschwindet,
                                // um Ressourcen zu sparen, wenn nicht sichtbar.
                                // videoPlayer.pause()
                            }
                    } else {
                        // Fallback, falls der Player nicht initialisiert werden konnte
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 300)
                            .overlay(Text("Video konnte nicht geladen werden").foregroundColor(.white))
                    }
                    // Kein ZStack mehr nötig, wenn VideoPlayer den ganzen Bereich einnimmt.
                    // Overlay-Text müsste anders platziert werden, wenn er über dem Video liegen soll.
                    // Für jetzt lassen wir den Text weg, um uns auf das Video zu konzentrieren.
                    
                    // 2. Bestseller Produkte Sektion (wie zuvor)
                    if !viewModel.bestsellerProducts.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Bestseller")
                                .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .semibold))
                                .padding([.top, .horizontal])
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppStyles.Spacing.medium) {
                                    ForEach(viewModel.bestsellerProducts) { product in // Annahme: Bestseller sind unique
                                        NavigationLink(value: product) {
                                            ProductCardView(product: product)
                                                .frame(width: 160)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal).padding(.bottom)
                            }
                        }.padding(.top) // Abstand nach dem Video-Banner
                    } else if viewModel.isLoading {
                        ProgressView("Lade Bestseller...").padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text("Fehler: \(errorMessage)").foregroundColor(AppColors.error).padding()
                    }

                    // Beispielhafter Inhalt, um Scrollen zu ermöglichen
                    ForEach(0..<5) { i in Text("Weiterer Inhalt \(i)...").padding().frame(maxWidth: .infinity, alignment: .leading) }
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
                print("HomeView onAppear.")
                // Initialisiere den Player und den Looper hier, damit das Video bereit ist
                if player == nil {
                    initializePlayer()
                }
                // Lade Bestseller-Daten
                if viewModel.bestsellerProducts.isEmpty && !viewModel.isLoading {
                    viewModel.loadDataForHomeView()
                }
            }
        }
    }

    private func initializePlayer() {
        guard let videoURL = Bundle.main.url(forResource: heroVideoNameInBundle, withExtension: videoFileExtension) else {
            print("HomeView ERROR: Video '\(heroVideoNameInBundle).\(videoFileExtension)' not found in bundle.")
            return
        }
        print("HomeView: Video URL found: \(videoURL)")

        let playerItem = AVPlayerItem(url: videoURL)
        self.queuePlayer = AVQueuePlayer(playerItem: playerItem) // AVQueuePlayer für Looping
        
        if let queuePlayer = self.queuePlayer {
            self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            queuePlayer.isMuted = true // Video stummschalten
            // Der Player für VideoPlayer-View ist der queuePlayer
            self.player = queuePlayer
            print("HomeView: AVPlayer and AVPlayerLooper initialized. Video should be ready.")
        } else {
            print("HomeView ERROR: Could not initialize AVQueuePlayer.")
        }
    }
}
