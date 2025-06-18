//
//  FooterView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: FooterView.swift
// PFAD: Core/UI/Components/FooterView.swift
// ZWECK: Eine wiederverwendbare Komponente, die den app-weiten Footer
//        mit rechtlichen Links, Service-Links und Zahlungsmethoden anzeigt.

import SwiftUI

struct FooterView: View {

    // MARK: - Eigenschaften
    private var currentYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
    
    // Eine Liste von Zahlungsmethoden-Bildern für einfache Iteration.
    private let paymentMethodImages = [
        "apple", "google", "maestro", "master", "pay", "union", "american"
    ]

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.large) {
            // Haupt-Inhaltsbereich mit Links
            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.large) {
                footerSection(title: "Rechtliches") {
                    footerLink(label: "Impressum", urlString: "https://www.your-garden-eden.de/impressum")
                    footerLink(label: "Datenschutzerklärung", urlString: "https://www.your-garden-eden.de/datenschutz")
                    footerLink(label: "AGB", urlString: "https://www.your-garden-eden.de/agb")
                    footerLink(label: "Widerrufsrecht", urlString: "https://www.your-garden-eden.de/widerrufsrecht")
                }
                
                footerSection(title: "Kundenservice") {
                    footerLink(label: "Kontakt", urlString: "https://www.your-garden-eden.de/kontakt")
                    footerLink(label: "Versand & Lieferung", urlString: "https://www.your-garden-eden.de/versand")
                }
                
                footerSection(title: "Folge uns") {
                    Button(action: { openURL(urlString: "https://www.instagram.com/yourgardeneden/") }) {
                        Image("instagram")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Layout.Spacing.large)

            Divider().padding(.vertical, AppTheme.Layout.Spacing.small)

            // Copyright- und Zahlungsmethoden-Bereich
            VStack(spacing: AppTheme.Layout.Spacing.medium) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Layout.Spacing.small) {
                        ForEach(paymentMethodImages, id: \.self) { imageName in
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 24)
                        }
                    }
                    .padding(.horizontal, AppTheme.Layout.Spacing.large)
                }
                
                Text("© \(currentYear) Your Garden Eden. Alle Rechte vorbehalten.")
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption, weight: .regular))
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, AppTheme.Layout.Spacing.large)
        .background(AppTheme.Colors.backgroundLightGray)
    }

    // MARK: - Subviews
    
    /// Erstellt eine Sektion mit einem Titel und Inhalt.
    @ViewBuilder
    private func footerSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.medium) {
            Text(title)
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.headline, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textHeadings)
            
            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.small) {
                content()
            }
        }
    }

    /// Erstellt einen klickbaren Text-Link, der eine URL öffnet.
    @ViewBuilder
    private func footerLink(label: String, urlString: String) -> some View {
        Button(action: { openURL(urlString: urlString) }) {
            Text(label)
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .regular))
                .foregroundColor(AppTheme.Colors.textLink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Helper Methoden
    
    /// Eine private Helferfunktion zum sicheren Öffnen von URLs.
    private func openURL(urlString: String) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            print("🔴 Fehler: Konnte URL nicht öffnen - \(urlString)")
            return
        }
        UIApplication.shared.open(url)
    }
}

//// MARK: - Preview
//struct FooterView_Previews: PreviewProvider {
//    static var previews: some View {
//        FooterView()
//            .previewLayout(.sizeThatFits)
//    }
//}
