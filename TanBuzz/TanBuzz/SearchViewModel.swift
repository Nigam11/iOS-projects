import Foundation
import FirebaseFirestore

class SearchViewModel: ObservableObject {
    @Published var searchResults: [User] = []
    private var db = Firestore.firestore()
    
    func searchUsers(query: String) {
        let lowercasedQuery = query.lowercased()

        db.collection("users")
            .order(by: "username")
            .start(at: [lowercasedQuery])
            .end(at: [lowercasedQuery + "\u{f8ff}"])
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching users: \(error.localizedDescription)")
                    return
                }

                self.searchResults = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: User.self)
                } ?? []
            }
    }
}
