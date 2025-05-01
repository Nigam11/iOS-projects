import Foundation
import FirebaseAuth
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentUserID: String = ""
    @Published var otherUserName: String = ""

    private var chatId: String?
    private var otherUserId: String
    private let db = Firestore.firestore()

    init(chatId: String?, otherUserId: String) {
        self.chatId = chatId
        self.otherUserId = otherUserId
        if let user = Auth.auth().currentUser {
            currentUserID = user.uid
        }
        fetchOtherUserName()
    }

    private func fetchOtherUserName() {
        db.collection("users").document(otherUserId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let name = data["name"] as? String {
                DispatchQueue.main.async {
                    self.otherUserName = name
                }
            }
        }
    }

    func sendMessage(content: String) {
        guard !content.isEmpty else { return }

        ChatService.shared.sendMessage(chatId: chatId, otherUserId: otherUserId, senderId: currentUserID, content: content) { [weak self] newChatId in
            self?.chatId = newChatId
            self?.fetchMessages()
        }
    }

    func fetchMessages() {
        guard let chatId = chatId else { return }

        db.collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }

                self.messages = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let id = data["id"] as? String ?? ""
                    let senderId = data["senderId"] as? String ?? ""
                    let content = data["content"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())

                    return Message(id: id, senderId: senderId, content: content, timestamp: timestamp)
                } ?? []
            }
    }
}
