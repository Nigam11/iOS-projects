import SwiftUI
import Firebase

@main
struct TanBuzzApp: App {
    @StateObject var authViewModel = AuthViewModel()
    init() {
            FirebaseApp.configure()
        }
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(authViewModel)
        }
    }
}

