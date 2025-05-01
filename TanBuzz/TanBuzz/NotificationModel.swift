import Foundation
import FirebaseFirestore
import FirebaseFirestore

struct NotificationModel: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore document ID
    var senderId: String
    var type: NotificationType
    var receiverId: String
    var timestamp: Date
    var isRead: Bool

    // Custom initializer for the NotificationModel
    init(id: String? = nil, senderId: String, type: NotificationType, receiverId: String, timestamp: Date, isRead: Bool) {
        self.id = id
        self.senderId = senderId
        self.type = type
        self.receiverId = receiverId
        self.timestamp = timestamp
        self.isRead = isRead
    }

    // CodingKeys to manage the mapping
    enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case type
        case receiverId
        case timestamp
        case isRead
    }
}
