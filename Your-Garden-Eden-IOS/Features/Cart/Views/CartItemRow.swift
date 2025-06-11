import SwiftUI

struct CartItemRow: View {
    
    // --- ANGEPASST ---
    // Der Typ der Eigenschaft wurde von WooCommerceStoreCartItem zu Item geändert.
    let item: Item
    // --- ENDE ANPASSUNG ---

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Optional: Produktbild anzeigen
            if let imageUrlString = item.images?.first?.thumbnail, let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("Menge: \(item.quantity)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()

                // --- ANGEPASST ---
                // Sicherer Zugriff auf den optionalen Preis
                Text(item.totals?.lineTotal ?? "N/A")
                    .font(.headline)
                    .fontWeight(.bold)
                // --- ENDE ANPASSUNG ---
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
