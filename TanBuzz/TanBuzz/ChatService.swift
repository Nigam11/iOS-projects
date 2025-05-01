import Foundation
import FirebaseFirestore
import FirebaseAuth

class ChatService {
    static let shared = ChatService()
    private let db = Firestore.firestore()

    func sendMessage(chatId: String?, otherUserId: String, senderId: String, content: String, completion: @escaping (String) -> Void) {
        let timestamp = Timestamp(date: Date())
        let message = Message(id: "", senderId: senderId, content: content, timestamp: timestamp)

        if let chatId = chatId {
            // Send message to existing chat
            self.sendMessage(to: chatId, message: message)

            // Update chat with last message and participants
            let chatRef = db.collection("chats").document(chatId)
            chatRef.updateData([
                "lastMessage": content,
                "lastMessageTimestamp": timestamp,
                "participants": FieldValue.arrayUnion([senderId, otherUserId]) // Ensure both users are added
            ]) { error in
                if let error = error {
                    print("Error updating chat: \(error.localizedDescription)")
                }
            }
            completion(chatId)
        } else {
            // Create new chat if no chatId exists
            let chatRef = db.collection("chats").document()
            let newChatId = chatRef.documentID
            let participants = [senderId, otherUserId]

            chatRef.setData([
                "participants": participants,
                "lastMessage": content,
                "lastMessageTimestamp": timestamp
            ]) { error in
                if let error = error {
                    print("Error creating chat: \(error.localizedDescription)")
                    return
                }
                self.sendMessage(to: newChatId, message: message)
                completion(newChatId)
            }
        }
    }

    func sendMessage(to chatId: String, message: Message) {
        let chatMessagesRef = db.collection("chats").document(chatId).collection("messages")
        let newDocRef = chatMessagesRef.document() // Get auto-generated Firestore ID
        let messageId = newDocRef.documentID

        newDocRef.setData([
            "id": messageId,
            "senderId": message.senderId,
            "content": message.content,
            "timestamp": message.timestamp
        ])
    }

    func fetchChats(forUser userId: String, completion: @escaping ([Chat]) -> Void) {
        db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching chats: \(error.localizedDescription)")
                    return
                }

                var chats: [Chat] = []
                for document in snapshot!.documents {
                    let data = document.data()
                    let chatId = document.documentID
                    let participants = data["participants"] as? [String] ?? []
                    let lastMessage = data["lastMessage"] as? String ?? ""
                    let lastMessageTimestamp = data["lastMessageTimestamp"] as? Timestamp ?? Timestamp(date: Date())

                    let chat = Chat(id: chatId, participants: participants, lastMessage: lastMessage, lastMessageTimestamp: lastMessageTimestamp.dateValue())
                    chats.append(chat)
                }

                completion(chats)
            }
    }

    // Delete chat from Firestore
    func deleteChat(_ chatId: String, completion: @escaping (Bool) -> Void) {
        db.collection("chats").document(chatId).delete { error in
            if let error = error {
                print("Error deleting chat: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
