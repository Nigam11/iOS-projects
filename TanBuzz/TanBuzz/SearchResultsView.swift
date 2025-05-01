import SwiftUI

struct SearchResultsView: View {
    @State var users: [User] // Assume this is populated with search results
    
    var body: some View {
        List(users) { user in
            NavigationLink(destination: UserProfileView(userId: user.id ?? "")) {
                HStack {
                    if let profileImageURL = user.profileImageURL, let url = URL(string: profileImageURL) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    Text(user.username)
                        .font(.headline)
                }
            }
        }
        .navigationTitle("Search Results")
    }
}
