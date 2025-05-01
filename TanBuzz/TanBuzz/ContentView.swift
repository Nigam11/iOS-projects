import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.userSession != nil {
                MainTabView()  // User is logged in
            } else {
                LoginView()  // User is not logged in
            }
        }
        .onAppear {
            authViewModel.fetchUser()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())  // For preview
    }
}
