import SwiftUI
import FirebaseFirestore

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    @State private var searchText: String = ""
    @State private var showDeleteConfirmation = false
    @State private var chatToDelete: Chat? = nil

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background matching the UserProfileView background colors
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.85, green: 0.98, blue: 1.0),
                        Color(red: 0.70, green: 0.92, blue: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search Bar
                    TextField("Search by name", text: $searchText)
                        .padding(12)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .padding([.top, .horizontal])
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 2)

                    List(viewModel.filteredChats(searchText: searchText), id: \.id) { chat in
                        if let otherUserId = chat.participants.first(where: { $0 != viewModel.currentUserID }) {
                            NavigationLink(destination: ChatView(chatId: chat.id, otherUserId: otherUserId)) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.9))
                                            .frame(width: 50, height: 50)
                                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)

                                        Text(viewModel.userNames[otherUserId]?.prefix(2).uppercased() ?? "??")
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipped()
                                    .padding(.leading, 4) // Slight inward padding

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(viewModel.userNames[otherUserId] ?? "User")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)

                                        if let lastMessage = chat.lastMessage {
                                            Text(lastMessage)
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                    }

                                    Spacer()

                                    if let date = chat.lastMessageTimestamp {
                                        Text(formatDate(date))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                    Menu {
                                        Button(action: {
                                            chatToDelete = chat
                                            showDeleteConfirmation = true
                                        }) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .rotationEffect(.degrees(90))
                                            .foregroundColor(.gray)
                                            .frame(width: 30, height: 44)
                                    }
                                }
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.85))
                                        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 2)
                                )
                                .padding([.horizontal])
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .navigationTitle("Messages")
                .onAppear {
                    viewModel.fetchChats()
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Chat"),
                    message: Text("Are you sure you want to delete this chat?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let chatToDelete = chatToDelete {
                            withAnimation {
                                if let index = viewModel.chats.firstIndex(where: { $0.id == chatToDelete.id }) {
                                    viewModel.chats.remove(at: index)
                                }
                            }
                            viewModel.deleteChat(chatToDelete)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}
