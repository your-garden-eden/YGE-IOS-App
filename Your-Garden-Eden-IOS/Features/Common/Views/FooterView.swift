// Features/Common/Views/FooterView.swift
import SwiftUI

struct FooterView: View {

    private var currentYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }

    private func openURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("FooterView Error: Invalid URL string: \(urlString)")
            return
        }
        UIApplication.shared.open(url) { success in
            if !success {
                print("FooterView Error: Failed to open URL: \(urlString)")
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.large) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
                    
                    footerSection(title: "Rechtliches") {
                        footerLink(label: "Impressum", action: { openURL(urlString: "https://www.your-garden-eden.de/impressum") })
                        footerLink(label: "Datenschutzerklärung", action: { openURL(urlString: "https://www.your-garden-eden.de/datenschutz") })
                        footerLink(label: "AGB", action: { openURL(urlString: "https://www.your-garden-eden.de/agb") })
                        footerLink(label: "Widerrufsrecht", action: { openURL(urlString: "https://www.your-garden-eden.de/widerrufsrecht") })
                    }

                    footerSection(title: "Kundenservice") {
                        footerLink(label: "Kontakt", action: { openURL(urlString: "https://www.your-garden-eden.de/kontakt") })
                        footerLink(label: "Versand & Lieferung", action: { openURL(urlString: "https://www.your-garden-eden.de/versand") })
                        footerLink(label: "FAQ", action: { openURL(urlString: "https://www.your-garden-eden.de/faq") })
                    }

                    footerSection(title: "Über uns") {
                        footerLink(label: "Wer wir sind", action: { openURL(urlString: "https://www.your-garden-eden.de/ueber-uns") })
                    }
                    
                   

                    footerSection(title: "Folge uns") {
                        Button {
                            openURL(urlString: "https://www.instagram.com/yourgardeneden/")
                        } label: {
                            Image("instagram")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 28, height: 28)
                        }
                    }
                }
                .padding(.horizontal, AppStyles.Spacing.medium)
            }

            Divider().padding(.vertical, AppStyles.Spacing.small)

            VStack(spacing: AppStyles.Spacing.medium) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppStyles.Spacing.small) {
                        Image("apple").resizable().scaledToFit().frame(height: 24)
                        Image("google").resizable().scaledToFit().frame(height: 24)
                        Image("maestro").resizable().scaledToFit().frame(height: 24)
                        Image("master").resizable().scaledToFit().frame(height: 24)
                        Image("pay").resizable().scaledToFit().frame(height: 24)
                        Image("union").resizable().scaledToFit().frame(height: 24)
                        Image("american").resizable().scaledToFit().frame(height: 24)
                    }
                    .padding(.horizontal, AppStyles.Spacing.medium)
                }

                Button {
                    openURL(urlString: "https://www.your-garden-eden.de")
                } label: {
                    Text("© \(currentYear) Your Garden Eden. Alle Rechte vorbehalten.")
                        .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .regular))
                        .foregroundColor(AppColors.textLink)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, AppStyles.Spacing.medium)
            }
            .frame(maxWidth: .infinity)
            
        }
        .padding(.vertical, AppStyles.Spacing.medium)
        .background(AppColors.backgroundLightGray)
    }

    @ViewBuilder
    private func footerSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            Text(title)
                // KORRIGIERTE Zeile:
                .font(AppFonts.montserrat(size: AppFonts.Size.caption, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
            
            VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
                content()
            }
        }
        .padding(.bottom, AppStyles.Spacing.small)
    }

    @ViewBuilder
    private func footerLink(label: String, action: @escaping () -> Void, isActive: Bool = true) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .regular))
                .foregroundColor(isActive ? AppColors.textLink : AppColors.textMuted.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
    }
}
