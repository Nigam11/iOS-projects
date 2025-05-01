import SwiftUI
import FirebaseAuth
import Firebase

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    var userId: String
    @State private var navigateToChat = false
    @State private var chatId: String = ""
    @State private var otherUserId: String = ""

    var body: some View {
        VStack {
            if let user = viewModel.user {
                HStack(alignment: .center, spacing: 16) {
                    // Profile Image
                    if let imageUrl = user.profileImageURL, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else if phase.error != nil {
                                Image(systemName: "person.crop.rectangle")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(.gray)
                                    .background(Color(.systemGray5))
                            } else {
                                ProgressView()
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: "person.crop.rectangle")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.gray)
                            .frame(width: 80, height: 80)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if let bio = user.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 16) {
                            VStack {
                                Text("Followers")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(user.followers.count)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }

                            VStack {
                                Text("Following")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(user.following.count)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.top, 8)
                    }
                    Spacer()
                }
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.89, green: 0.96, blue: 1.0), Color(red: 0.76, green: 0.89, blue: 0.98)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                VStack(spacing: 12) {
                    // Follow Button
                    Button(action: {
                        if !viewModel.isFollowed && !viewModel.isFollowRequestPending {
                            viewModel.sendFollowRequest(receiverId: userId)
                        }
                    }) {
                        Text(buttonTitle)
                            .font(.subheadline.bold())
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(buttonBackground)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.isFollowed || viewModel.isFollowRequestPending)

                    // Chat Button – Only visible if follow request is accepted
                    if viewModel.isFollowed {
                        Button(action: {
                            createOrFetchChat(with: userId) { id in
                                self.chatId = id
                                self.otherUserId = userId
                                self.navigateToChat = true
                            }
                        }) {
                            Text("Chat")
                                .font(.subheadline.bold())
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                        }
                        .foregroundColor(.blue)
                    }

                    // NavigationLink
                    NavigationLink(destination: ChatView(chatId: chatId, otherUserId: otherUserId), isActive: $navigateToChat) {
                        EmptyView()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            } else {
                ProgressView()
            }
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.89, green: 0.96, blue: 1.0), Color(red: 0.76, green: 0.89, blue: 0.98)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding()
        .onAppear {
            viewModel.fetchUserProfile(userId: userId)
            viewModel.checkFollowStatus(userId: userId)
        }
        .alert(isPresented: $viewModel.showRequestSentPopup) {
            Alert(
                title: Text("Follow Request Sent"),
                message: Text("Your follow request has been sent successfully."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var buttonTitle: String {
        if viewModel.isFollowed {
            return "Following"
        } else if viewModel.isFollowRequestPending {
            return "Request Sent"
        } else {
            return "Follow"
        }
    }

    private var buttonBackground: Color {
        if viewModel.isFollowed {
            return Color.green
        } else if viewModel.isFollowRequestPending {
            return Color.gray
        } else {
            return Color.blue
        }
    }

    private func createOrFetchChat(with userId: String, completion: @escaping (String) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let chatsRef = db.collection("chats")

        chatsRef
            .whereField("participants", arrayContains: currentUserId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking for existing chat: \(error)")
                    return
                }

                if let documents = snapshot?.documents {
                    for doc in documents {
                        let participants = doc.data()["participants"] as? [String] ?? []
                        if participants.contains(userId) {
                            completion(doc.documentID)
                            return
                        }
                    }
                }

                // No existing chat found, create a new one
                let newChatRef = chatsRef.document()
                let data: [String: Any] = [
                    "participants": [currentUserId, userId],
                    "lastMessage": "",
                    "lastMessageTimestamp": Timestamp()
                ]
                newChatRef.setData(data) { error in
                    if let error = error {
                        print("Error creating chat: \(error)")
                    } else {
                        completion(newChatRef.documentID)
                    }
                }
            }
    }
}
