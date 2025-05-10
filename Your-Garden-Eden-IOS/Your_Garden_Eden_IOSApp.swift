import SwiftUI
import FirebaseCore 
@main
struct Your_Garden_Eden_IOSApp: App {
    init() {
        FirebaseApp.configure()
        print("Firebase configured!")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
