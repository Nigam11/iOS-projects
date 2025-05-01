import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID
    var username: String
    var name: String
    var email: String
    var bio: String?
    var profileImageURL: String?
    var isPrivate: Bool
    var followers: [String]
    var following: [String]
    var location: String?
    var socialLinks: [String: String]?
}
