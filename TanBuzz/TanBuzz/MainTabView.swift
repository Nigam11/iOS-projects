import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var searchViewModel = SearchViewModel()

    var body: some View {
        TabView {
            ChatListView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                        .font(.system(size: 16, weight: .medium))
                }

            NotificationListView()
                .tabItem {
                    Label("Notifications", systemImage: "bell.fill")
                        .font(.system(size: 16, weight: .medium))
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                        .font(.system(size: 16, weight: .medium))
                }
        }
        
    }
}

