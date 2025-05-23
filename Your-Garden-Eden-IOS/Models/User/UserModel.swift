// Your-Garden-Eden-IOS/Models/UserModel.swift (oder ein anderer Name)

import Foundation
import FirebaseAuth // Wichtig für den Initializer

struct UserModel: Identifiable, Codable { // Codable ist gut für Persistenz oder API-Calls
    let id: String                  // Firebase UID, wird als Identifiable.id verwendet
    let email: String?
    var displayName: String?        // Kann von Firebase kommen oder später gesetzt werden
    var firstName: String?          // Für WooCommerce und App-interne Verwendung
    var lastName: String?           // Für WooCommerce und App-interne Verwendung
    var wooCommerceCustomerId: Int? // Wird nach erfolgreichem Link gesetzt

    // Initializer, der einen Firebase User entgegennimmt
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email
        self.displayName = firebaseUser.displayName
        // firstName und lastName sind hier noch nicht bekannt,
        // sie kommen von der Registrierung oder werden später gesetzt.
    }

    // Ein weiterer Initializer für Flexibilität (z.B. für Previews oder Tests)
    init(id: String, email: String?, displayName: String? = nil, firstName: String? = nil, lastName: String? = nil, wooCommerceCustomerId: Int? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.firstName = firstName
        self.lastName = lastName
        self.wooCommerceCustomerId = wooCommerceCustomerId
    }

    // Placeholder für SwiftUI Previews, falls benötigt
    static var placeholder: UserModel {
        UserModel(
            id: "placeholderUID123",
            email: "user@example.com",
            displayName: "Placeholder User",
            firstName: "Test",
            lastName: "User",
            wooCommerceCustomerId: nil
        )
    }
}
