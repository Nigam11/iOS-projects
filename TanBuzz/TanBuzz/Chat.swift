import Foundation

struct Chat: Identifiable,Decodable {
    let id: String
    let participants: [String]
    let lastMessage: String?
    let lastMessageTimestamp: Date?
}
