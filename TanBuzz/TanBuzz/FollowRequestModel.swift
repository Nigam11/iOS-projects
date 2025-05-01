import Foundation
import FirebaseFirestore

struct FollowRequest: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var receiverId: String
    var status: String // "pending", "accepted", "rejected"
}
