import FirebaseFirestore
import FirebaseAuth
import Foundation

class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    
    private var db = Firestore.firestore()
    
    // Fetch notifications for the current user
    func fetchNotifications() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("notifications")
            .whereField("receiverId", isEqualTo: currentUserId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching notifications: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot {
                    self.notifications = snapshot.documents.compactMap { doc in
                        let data = doc.data()
                        let senderId = data["senderId"] as? String ?? ""
                        let receiverId = data["receiverId"] as? String ?? ""
                        
                        // Convert Firestore data for 'type' into NotificationType enum
                        let typeString = data["type"] as? String ?? ""
                        let type: NotificationType
                        switch typeString {
                        case "followRequest":
                            type = .followRequest
                        case "like":
                            type = .like
                        default:
                            type = .followRequest // Default case, you can change it based on your needs
                        }
                        
                        // Convert Firestore Timestamp to Swift Date
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        let isRead = data["isRead"] as? Bool ?? false
                        
                        return NotificationModel(
                            id: doc.documentID,
                            senderId: senderId,
                            type: type,
                            receiverId: receiverId,
                            timestamp: timestamp,
                            isRead: isRead
                        )
                    }
                }
            }
    }
    
    // Accept or reject follow request
    func updateFollowRequest(notificationId: String, accept: Bool) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let notificationRef = db.collection("notifications").document(notificationId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let notificationDoc = try transaction.getDocument(notificationRef)
                
                guard let notificationData = notificationDoc.data(),
                      let senderId = notificationData["senderId"] as? String,
                      let receiverId = notificationData["receiverId"] as? String else {
                    print("Invalid notification data")
                    return nil
                }
                
                // Update notification status
                transaction.updateData([
                    "status": accept ? "accepted" : "rejected",
                    "isRead": true // Mark as read when processed
                ], forDocument: notificationRef)
                
                if accept {
                    // Update users' followers/following
                    let receiverRef = self.db.collection("users").document(receiverId)
                    transaction.updateData([
                        "followers": FieldValue.arrayUnion([senderId])
                    ], forDocument: receiverRef)
                    
                    let senderRef = self.db.collection("users").document(senderId)
                    transaction.updateData([
                        "following": FieldValue.arrayUnion([receiverId])
                    ], forDocument: senderRef)
                    
                    // Remove receiver from pending requests
                    transaction.updateData([
                        "pendingFollowRequests": FieldValue.arrayRemove([receiverId])
                    ], forDocument: senderRef)
                }
                
            } catch let error as NSError {
                errorPointer?.pointee = error
                print("Transaction failed: \(error.localizedDescription)")
                return nil
            }
            return nil
            
        }, completion: { (_, error) in
            if let error = error {
                print("Error updating follow request: \(error.localizedDescription)")
            } else {
                print(accept ? "Follow request accepted!" : "Follow request rejected!")
            }
        })
    }
}
