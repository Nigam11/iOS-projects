import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                TextField("Search by username...", text: $searchText)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                    .onChange(of: searchText) { newValue in
                        viewModel.searchUsers(query: newValue)
                    }

                List(viewModel.searchResults) { user in
                    NavigationLink(destination: UserProfileView(userId: user.id ?? "")) {
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("@\(user.username)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Search")
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.85, green: 0.98, blue: 1.0), Color(red: 0.70, green: 0.92, blue: 1.0)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }
}
