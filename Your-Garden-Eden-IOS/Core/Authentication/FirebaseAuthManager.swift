import Foundation
import FirebaseAuth
// Importiere GoogleSignIn später, wenn du es implementierst
// import GoogleSignIn

class FirebaseAuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private var authStateHandler: AuthStateDidChangeListenerHandle?

    init() {
        self.authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            DispatchQueue.main.async {
                self?.user = user
            }
        }
    }

    deinit {
        if let authStateHandler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(authStateHandler)
        }
    }

    func signInWithEmail(email: String, password: String) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
            }
        }
    }

    func signUpWithEmail(email: String, password: String, additionalData: [String: Any]? = nil) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let firebaseUser = authResult?.user else {
                    self?.isLoading = false
                    self?.errorMessage = "Firebase Nutzer konnte nicht erstellt werden."
                    return
                }
                
                self?.linkUserToWooCommerce(firebaseUser: firebaseUser, additionalData: additionalData)
            }
        }
    }
    
    // func signInWithGoogle(presentingViewController: UIViewController) { ... }

    func signOut() {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch let signOutError as NSError {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            }
        }
    }

    private func linkUserToWooCommerce(firebaseUser: FirebaseAuth.User, additionalData: [String: Any]?) {
        // isLoading ist bereits true vom signUpWithEmail Aufruf
        
        guard let email = firebaseUser.email else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Firebase Nutzerdaten unvollständig für WooCommerce Verknüpfung (E-Mail fehlt)."
            }
            // Hier könnte man optional den Firebase User wieder löschen, da die Verknüpfung kritisch ist
            // firebaseUser.delete { _ in }
            return
        }

        var requestData: [String: Any] = [
            "firebaseUid": firebaseUser.uid,
            "email": email
        ]
        if let firstName = additionalData?["firstName"] as? String, !firstName.isEmpty {
            requestData["firstName"] = firstName
        }
        if let lastName = additionalData?["lastName"] as? String, !lastName.isEmpty {
            requestData["lastName"] = lastName
        }
        
        print("FirebaseAuthManager: VORBEREITUNG zum Aufruf der Cloud Function 'createOrLinkWooCommerceCustomer' mit Daten: \(requestData)")
        print("FirebaseAuthManager: AKTUELL WIRD DER AUFRUF SIMULIERT / ÜBERSPRUNGEN, da die Cloud Function noch nicht implementiert ist.")

        // --- BEGINN SIMULATION / ÜBERSPRINGEN ---
        // Setze isLoading auf false und tue so, als wäre es erfolgreich, damit die UI weitergeht.
        // Der Nutzer ist in Firebase registriert, aber noch nicht mit WooCommerce verknüpft.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Kleine Verzögerung, um "Arbeit" zu simulieren
            self.isLoading = false
            // self.errorMessage = "Hinweis: Shop-Konto Verknüpfung ist noch nicht aktiv." // Optionaler Hinweis für dich beim Testen
            print("FirebaseAuthManager: WooCommerce-Verknüpfung SIMULIERT/ÜBERSPRUNGEN. Nutzer ist in Firebase registriert.")
            // Da self.user bereits durch den AuthStateChangeListener gesetzt wurde,
            // sollte das Auth-Sheet sich jetzt schließen.
        }
        // --- ENDE SIMULATION / ÜBERSPRINGEN ---

        /*
        // --- ECHTER AUFRUF (später wieder aktivieren) ---
        struct LinkWooCommerceResponse: Decodable { // Dummy-Struktur
            let success: Bool
            let message: String?
            let woocommerceCustomerId: Int?
        }

        FirebaseProxyService.shared.callFunction(
            functionName: "createOrLinkWooCommerceCustomer",
            data: requestData
        ) { [weak self] (result: Result<LinkWooCommerceResponse, FirebaseProxyService.ProxyServiceError>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                 switch result {
                 case .success(let response):
                     if response.success {
                         print("WooCommerce Kunde erfolgreich verknüpft/erstellt. WC ID: \(response.woocommerceCustomerId ?? -1)")
                     } else {
                         print("Fehler von Cloud Function bei WooCommerce Kundenverknüpfung: \(response.message ?? "Unbekannter Fehler von CF")")
                         self?.errorMessage = response.message ?? "Fehler bei der Verknüpfung mit dem Shop-Konto."
                         // Hier Logik zum Löschen des Firebase Users einfügen, falls gewünscht
                     }
                 case .failure(let error):
                     print("Netzwerk-/Funktionsfehler bei WooCommerce Kundenverknüpfung: \(error)")
                     self?.errorMessage = "Netzwerkfehler oder technisches Problem bei der Verknüpfung mit dem Shop-Konto."
                     // Hier Logik zum Löschen des Firebase Users einfügen, falls gewünscht
                 }
            }
        }
        // --- ENDE ECHTER AUFRUF ---
        */
    }
}
