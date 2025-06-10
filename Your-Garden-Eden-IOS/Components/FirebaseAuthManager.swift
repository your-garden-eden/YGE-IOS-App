// Core/Authentication/FirebaseAuthManager.swift
import Foundation
import FirebaseAuth
import Combine

class FirebaseAuthManager: ObservableObject {
    // MARK: - Singleton Instance
    static let shared = FirebaseAuthManager()

    // MARK: - Published Properties
    @Published var user: UserModel?
    @Published var authError: Error? {
        didSet {
            if authError != nil {
                errorID = UUID()
            } else if oldValue != nil && authError == nil {
                errorID = UUID()
            }
        }
    }
    @Published private(set) var errorID: UUID = UUID()
    @Published var isLoading: Bool = false

    // MARK: - Private Properties
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    // Annahme: FirebaseProxyService ist auch ein Singleton oder wird hier korrekt initialisiert
    private let firebaseProxyService: FirebaseProxyService

    // MARK: - Initializer (private für Singleton)
    private init(firebaseProxyService: FirebaseProxyService = .shared) { // Verwende .shared, wenn FirebaseProxyService ein Singleton ist
        self.firebaseProxyService = firebaseProxyService
        registerAuthStateHandler()
        print("FirebaseAuthManager initialized (Singleton). Auth state listener registered.")
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
                    if self.user?.id != fbUser.uid || self.user == nil {
                        self.user = UserModel(firebaseUser: fbUser)
                        print("FirebaseAuthManager: User state changed. Mapped to UserModel. UID: \(fbUser.uid)")
                    }
                } else {
                    if self.user != nil {
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
            self.authError = nil
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.authError = error
                    print("Error signing in: \(error.localizedDescription)")
                    return
                }
                if authResult?.user != nil {
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
            self.authError = nil
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.authError = error
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
            DispatchQueue.main.async {
                 if self.user != nil {
                    self.user?.firstName = firstName
                    self.user?.lastName = lastName
                } else {
                    self.user = UserModel(firebaseUser: firebaseUser)
                    self.user?.firstName = firstName
                    self.user?.lastName = lastName
                }
                print("UserModel updated/created with firstName and lastName.")
            }
            print("User \(firebaseUser.uid) signed up successfully in Firebase.")
            self.linkUserToWooCommerce(firebaseUser: firebaseUser, firstName: firstName, lastName: lastName)
        }
    }

    func signOut() {
        DispatchQueue.main.async {
            self.isLoading = true
            self.authError = nil
        }
        do {
            try Auth.auth().signOut()
            print("User signed out successfully from Firebase.")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch let signOutError as NSError {
            print("Error signing out from Firebase: %@", signOutError.localizedDescription)
            DispatchQueue.main.async {
                self.isLoading = false
                self.authError = signOutError
            }
        }
    }

    // MARK: - WooCommerce Linking
    private func linkUserToWooCommerce(firebaseUser: FirebaseAuth.User, firstName: String?, lastName: String?) {
        print("Attempting to link Firebase user \(firebaseUser.uid) to WooCommerce...")
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
                self.isLoading = false
                switch result {
                case .success(let response):
                    print("Successfully linked/created WooCommerce customer. ID: \(response.wooCommerceCustomerId), Status: \(response.status)")
                    if self.user != nil {
                        self.user?.wooCommerceCustomerId = response.wooCommerceCustomerId
                    }
                    self.authError = nil
                case .failure(let firebaseError):
                    print("Failed to link/create WooCommerce customer: \(firebaseError.localizedDescription)")
                    self.authError = firebaseError
                }
            }
        }
    }
}
