// Your-Garden-Eden-IOS/Core/Managers/FirebaseAuthManager.swift

import Foundation
import FirebaseAuth
import Combine // Für UUID und @Published

class FirebaseAuthManager: ObservableObject {
    // MARK: - Published Properties
    @Published var user: UserModel?
    
    @Published var authError: Error? {
        didSet {
            // Diese Logik stellt sicher, dass errorID aktualisiert wird,
            // wenn authError sich ändert (ein neuer Fehler auftritt ODER ein Fehler gelöscht wird).
            if authError != nil { // Ein neuer Fehler ist aufgetreten
                errorID = UUID()
            } else if oldValue != nil && authError == nil { // Ein alter Fehler wurde explizit gelöscht
                errorID = UUID()
            }
            // Wenn authError und oldValue beide nil sind, keine Änderung an errorID nötig.
        }
    }
    @Published private(set) var errorID: UUID = UUID() // Trigger für .onChange in der View
    
    @Published var isLoading: Bool = false

    // MARK: - Private Properties
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private let firebaseProxyService: FirebaseProxyService

    // MARK: - Initializer
    init(firebaseProxyService: FirebaseProxyService = .shared) {
        self.firebaseProxyService = firebaseProxyService
        registerAuthStateHandler()
        print("FirebaseAuthManager initialized. Auth state listener registered.")
    }

    // MARK: - Deinitializer
    deinit {
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
            print("FirebaseAuthManager deinitialized. Auth state listener removed.")
        }
    }

    // MARK: - Authentication State Handling
    private func registerAuthStateHandler() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] (auth, firebaseAuthUser) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let fbUser = firebaseAuthUser {
                    // Nur neu setzen oder aktualisieren, wenn sich die UID ändert oder user vorher nil war
                    if self.user?.id != fbUser.uid || self.user == nil {
                        self.user = UserModel(firebaseUser: fbUser)
                        print("FirebaseAuthManager: User state changed. Mapped to UserModel. UID: \(fbUser.uid)")
                    }
                } else {
                    if self.user != nil { // Nur ändern, wenn vorher ein User da war
                        self.user = nil
                        print("FirebaseAuthManager: User is signed out.")
                    }
                }
            }
        }
    }

    // MARK: - Public Authentication Methods
    func signInWithEmail(email: String, password: String) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.authError = nil // Fehler zurücksetzen -> löst errorID Update aus
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.authError = error // Fehler setzen -> löst errorID Update aus
                    print("Error signing in: \(error.localizedDescription)")
                    return
                }
                
                if authResult?.user != nil {
                    // self.user wird durch den authStateHandler aktualisiert.
                    // authError bleibt nil (wurde oben schon gesetzt)
                    print("User signed in successfully: \(authResult?.user.uid ?? "N/A")")
                } else {
                    self.authError = NSError(
                        domain: "FirebaseAuthManager.signIn",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Sign in failed: User data not available after operation."]
                    )
                    print("Sign in attempt completed, but user data not found.")
                }
            }
        }
    }

    func signUpWithEmail(email: String, password: String, firstName: String, lastName: String) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.authError = nil // Fehler zurücksetzen -> löst errorID Update aus
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.authError = error // Fehler setzen -> löst errorID Update aus
                    print("Error signing up: \(error.localizedDescription)")
                }
                return
            }

            guard let firebaseUser = authResult?.user else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.authError = NSError(
                        domain: "FirebaseAuthManager.signUp",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Sign up failed: User not found after creation."]
                    )
                    print("User not found after sign up.")
                }
                return
            }
            
            // self.user wird durch den authStateHandler aktualisiert.
            // Wir müssen es aber noch mit firstName und lastName anreichern.
            DispatchQueue.main.async {
                 if self.user != nil {
                    self.user?.firstName = firstName
                    self.user?.lastName = lastName
                } else {
                    // Fallback, falls der Listener noch nicht durchgelaufen ist
                    self.user = UserModel(firebaseUser: firebaseUser)
                    self.user?.firstName = firstName
                    self.user?.lastName = lastName
                }
                print("UserModel updated/created with firstName and lastName.")
            }
           
            print("User \(firebaseUser.uid) signed up successfully in Firebase.")
            // isLoading bleibt true bis linkUserToWooCommerce fertig ist
            self.linkUserToWooCommerce(firebaseUser: firebaseUser, firstName: firstName, lastName: lastName)
        }
    }

    func signOut() {
        DispatchQueue.main.async {
            self.isLoading = true // Optional
            self.authError = nil // Fehler zurücksetzen
        }
        
        do {
            try Auth.auth().signOut()
            // self.user wird durch den authStateHandler auf nil gesetzt.
            print("User signed out successfully from Firebase.")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch let signOutError as NSError {
            print("Error signing out from Firebase: %@", signOutError.localizedDescription)
            DispatchQueue.main.async {
                self.isLoading = false
                self.authError = signOutError // Fehler setzen
            }
        }
    }

    // MARK: - WooCommerce Linking
    private func linkUserToWooCommerce(firebaseUser: FirebaseAuth.User, firstName: String?, lastName: String?) {
        print("Attempting to link Firebase user \(firebaseUser.uid) to WooCommerce...")
        // isLoading ist bereits true von signUpWithEmail

        let requestData = CreateOrLinkWooCommerceCustomerRequest(
            firebaseUid: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            firstName: firstName,
            lastName: lastName
        )

        firebaseProxyService.callFunction(
            functionName: "createOrLinkWooCommerceCustomer",
            requestDataObject: requestData
        ) { [weak self] (result: Result<CreateOrLinkWooCommerceCustomerResponse, FirebaseError>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false // Wichtig: isLoading hier beenden

                switch result {
                case .success(let response):
                    print("Successfully linked/created WooCommerce customer. ID: \(response.wooCommerceCustomerId), Status: \(response.status)")
                    if self.user != nil {
                        self.user?.wooCommerceCustomerId = response.wooCommerceCustomerId
                    }
                    self.authError = nil // Erfolgreich, also Fehler löschen
                case .failure(let firebaseError):
                    print("Failed to link/create WooCommerce customer: \(firebaseError.localizedDescription)")
                    self.authError = firebaseError // Fehler setzen
                }
            }
        }
    }
}
