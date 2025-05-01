import Foundation
import FirebaseFirestore

struct Message: Identifiable {
    var id: String
    var senderId: String
    var content: String
    var timestamp: Timestamp
}
