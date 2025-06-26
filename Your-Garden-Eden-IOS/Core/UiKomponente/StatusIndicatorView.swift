// DATEI: ComponentViews.swift
// PFAD: Core/UI/Components/ComponentViews.swift
// VERSION: 1.0 (KONSOLIDIERT & FINAL)
// STATUS: Sammlung stabiler, wiederverwendbarer UI-Komponenten.

import SwiftUI
import SafariServices
import UIKit

// MARK: - StatusIndicatorView
struct StatusIndicatorView: View {
    let style: StatusIndicatorStyle
    let displayMode: StatusIndicatorDisplayMode
    
    var body: some View {
        switch displayMode {
        case .banner:
            bannerView
        case .fullScreen:
            fullScreenView
        }
    }
    
    private var bannerView: some View {
        HStack(spacing: AppTheme.Layout.Spacing.small) {
            Image(systemName: style.iconName)
            Text(style.message)
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.subheadline, weight: .semibold))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(style.color)
        .foregroundColor(AppTheme.Colors.textOnPrimary)
        .cornerRadius(AppTheme.Layout.BorderRadius.large)
        .appShadow(AppTheme.Shadows.medium)
        .padding(.horizontal)
    }
    
    private var fullScreenView: some View {
        VStack(spacing: AppTheme.Layout.Spacing.medium) {
            Image(systemName: style.iconName)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(style.color)
            
            Text(style.message)
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.body))
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension StatusIndicatorView {
    static func errorState(message: String) -> some View {
        StatusIndicatorView(style: .error(message: message), displayMode: .fullScreen)
    }
    
    static func successBanner(message: String) -> some View {
        StatusIndicatorView(style: .success(message: message), displayMode: .banner)
    }
    
    static func errorBanner(message: String) -> some View {
        StatusIndicatorView(style: .error(message: message), displayMode: .banner)
    }
}


// MARK: - ShimmerView
struct ShimmerView: View {
    private let gradient = Gradient(colors: [
        AppTheme.Colors.backgroundLightGray,
        AppTheme.Colors.borderLight.opacity(0.8),
        AppTheme.Colors.backgroundLightGray
    ])
    
    @State private var startPoint: UnitPoint = .init(x: -1.8, y: -1.2)
    @State private var endPoint: UnitPoint = .init(x: 0, y: -0.2)
    
    var body: some View {
        LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                startPoint = .init(x: 1, y: 1)
                endPoint = .init(x: 2.8, y: 2.2)
            }
        }
    }
}

// MARK: - SafariWebView
struct SafariWebView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let vc = SFSafariViewController(url: url, configuration: config)
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - QuantitySelectorView
public struct QuantitySelectorView: View {
    @Binding var quantity: Int

    public var body: some View {
        HStack(spacing: AppTheme.Layout.Spacing.medium) {
            Text("Menge:")
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.headline, weight: .medium))
                .foregroundColor(AppTheme.Colors.textHeadings)

            Spacer()

            Button { if quantity > 1 { quantity -= 1 } } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundColor(quantity > 1 ? AppTheme.Colors.primaryDark : AppTheme.Colors.textMuted.opacity(0.5))
            }.disabled(quantity <= 1)

            Text("\(quantity)")
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.title2, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textBase)
                .frame(minWidth: 40, alignment: .center)

            Button { quantity += 1 } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.Colors.primaryDark)
            }
        }
        .padding(.vertical, AppTheme.Layout.Spacing.small)
        .buttonStyle(.plain)
    }
}


// MARK: - LoadingOverlayView
struct LoadingOverlayView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(1.5)
        }
    }
}

// MARK: - FooterView
struct FooterView: View {
    private var currentYear: String {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy"; return formatter.string(from: Date())
    }
    
    private let paymentMethodImages = ["apple", "google", "maestro", "master", "pay", "union", "american"]

    var body: some View {
        VStack(spacing: AppTheme.Layout.Spacing.large) {
            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.large) {
                footerSection(title: "Rechtliches") {
                    footerLink(label: "Impressum", urlString: "https://www.your-garden-eden.de/impressum")
                    footerLink(label: "Datenschutzerklärung", urlString: "https://www.your-garden-eden.de/datenschutz")
                    footerLink(label: "AGB", urlString: "https://www.your-garden-eden.de/agb")
                }
                footerSection(title: "Kundenservice") {
                    footerLink(label: "Kontakt", urlString: "https://www.your-garden-eden.de/kontakt")
                    footerLink(label: "Versand & Lieferung", urlString: "https://www.your-garden-eden.de/versand")
                }
            }.padding(.horizontal, AppTheme.Layout.Spacing.large)

            Divider().padding(.vertical, AppTheme.Layout.Spacing.small)

            VStack(spacing: AppTheme.Layout.Spacing.medium) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Layout.Spacing.small) {
                        ForEach(paymentMethodImages, id: \.self) { imageName in
                            Image(imageName).resizable().scaledToFit().frame(height: 24)
                        }
                    }.padding(.horizontal, AppTheme.Layout.Spacing.large)
                }
                Text("© \(currentYear) Your Garden Eden. Alle Rechte vorbehalten.")
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption, weight: .regular))
                    .foregroundColor(AppTheme.Colors.textMuted)
            }.frame(maxWidth: .infinity)
        }
        .padding(.vertical, AppTheme.Layout.Spacing.large)
        .background(AppTheme.Colors.backgroundLightGray)
    }

    @ViewBuilder private func footerSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.medium) {
            Text(title).font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.headline, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textHeadings)
            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.small) { content() }
        }
    }

    @ViewBuilder private func footerLink(label: String, urlString: String) -> some View {
        Button(action: {
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }) {
            Text(label)
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
                .foregroundColor(AppTheme.Colors.textLink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - ExpandableTextView
public struct ExpandableTextView: View {
    private let text: String
    private let lineLimit: Int
    @State private var isExpanded: Bool = false
    @State private var isTruncated: Bool = false

    public init(text: String, lineLimit: Int = 5) {
        self.text = text.strippingHTML()
        self.lineLimit = lineLimit
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
                .foregroundColor(AppTheme.Colors.textMuted)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(GeometryReader { geometry in Color.clear.onAppear { determineTruncation(geometry: geometry) } })
            
            if isTruncated {
                Button(action: { withAnimation(.easeInOut) { isExpanded.toggle() } }) {
                    Text(isExpanded ? "Weniger anzeigen" : "Mehr anzeigen")
                        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private func determineTruncation(geometry: GeometryProxy) {
        let uiFont = UIFont.roboto(size: AppTheme.Fonts.Size.body)
        let totalRect = text.boundingRect(with: CGSize(width: geometry.size.width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: uiFont], context: nil)
        if totalRect.size.height > geometry.size.height {
            self.isTruncated = true
        }
    }
}
