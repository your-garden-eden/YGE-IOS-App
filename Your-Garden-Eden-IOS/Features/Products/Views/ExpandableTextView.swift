// Path: Your-Garden-Eden-IOS/Features/Products/Views/ExpandableTextView.swift

import SwiftUI

struct ExpandableTextView: View {
    let text: String
    let collapsedLineLimit: Int
    
    @State private var isExpanded: Bool = false
    @State private var isTruncated: Bool = false

    init(text: String, lineLimit: Int = 4) {
        self.text = text.strippingHTML() // HTML wird hier direkt entfernt
        self.collapsedLineLimit = lineLimit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            Text(text)
                .font(AppFonts.roboto(size: AppFonts.Size.body))
                .foregroundColor(AppColors.textMuted)
                .lineLimit(isExpanded ? nil : collapsedLineLimit)
                .background(
                    Text(text)
                        .lineLimit(collapsedLineLimit)
                        .background(GeometryReader { geo in
                            Color.clear.onAppear {
                                let size = geo.size
                                let fullSize = text.boundingRect(
                                    with: CGSize(width: size.width, height: .greatestFiniteMagnitude),
                                    options: .usesLineFragmentOrigin,
                                    attributes: [.font: UIFont.systemFont(ofSize: AppFonts.Size.body)],
                                    context: nil
                                ).size
                                
                                if fullSize.height > size.height {
                                    isTruncated = true
                                }
                            }
                        })
                        .hidden() // Versteckt die Mess-View
                )

            if isTruncated {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    Text(isExpanded ? "Weniger anzeigen" : "Mehr anzeigen")
                        .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
            }
        }
    }
}
