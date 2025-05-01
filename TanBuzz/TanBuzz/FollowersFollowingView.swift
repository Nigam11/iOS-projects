import SwiftUI

enum FollowType {
    case followers
    case following
}

struct FollowersFollowingView: View {
    let type: FollowType
    @ObservedObject var viewModel: FollowersFollowingViewModel

    init(type: FollowType, user: User?) {
        self.type = type
        self.viewModel = FollowersFollowingViewModel(user: user, type: type)
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.85, green: 0.98, blue: 1.0),
                        Color(red: 0.70, green: 0.92, blue: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                List {
                    ForEach(viewModel.users) { user in
                        HStack {
                            Text(user.username)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)

                            Spacer()

                            Button(action: {
                                viewModel.removeUser(user)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 3)
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(type == .followers ? "Followers" : "Following")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.blue)
    }
}
