import Foundation
import FirebaseFirestore
import FirebaseAuth

class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var currentUserID: String = ""
    @Published var userNames: [String: String] = [:]  // UID → Name

    private let db = Firestore.firestore()

    init() {
        if let user = Auth.auth().currentUser {
            currentUserID = user.uid
        }
    }

    func fetchChats() {
        guard !currentUserID.isEmpty else { return }

        ChatService.shared.fetchChats(forUser: currentUserID) { [weak self] chats in
            DispatchQueue.main.async {
                self?.chats = chats
                self?.fetchUserNames(for: chats)
            }
        }
    }

    func deleteChat(_ chat: Chat) {
        // Delete chat from Firestore
        db.collection("chats").document(chat.id).delete { error in
            if let error = error {
                print("Error deleting chat: \(error.localizedDescription)")
            } else {
                // Successfully deleted from Firestore, now remove from local list
                DispatchQueue.main.async {
                    if let index = self.chats.firstIndex(where: { $0.id == chat.id }) {
                        self.chats.remove(at: index)
                    }
                }
            }
        }
    }

    private func fetchUserNames(for chats: [Chat]) {
        let otherUserIds = Set(
            chats.compactMap { chat in
                chat.participants.first(where: { $0 != self.currentUserID })
            }
        )

        for uid in otherUserIds {
            if userNames[uid] != nil { continue }

            db.collection("users").document(uid).getDocument { snapshot, error in
                if let data = snapshot?.data(), let name = data["name"] as? String {
                    DispatchQueue.main.async {
                        self.userNames[uid] = name
                    }
                }
            }
        }
    }

    // Filter chats based on the search text
    func filteredChats(searchText: String) -> [Chat] {
        guard !searchText.isEmpty else { return chats }

        return chats.filter { chat in
            if let otherUserId = chat.participants.first(where: { $0 != currentUserID }) {
                return userNames[otherUserId]?.lowercased().contains(searchText.lowercased()) ?? false
            }
            return false
        }
    }
}
