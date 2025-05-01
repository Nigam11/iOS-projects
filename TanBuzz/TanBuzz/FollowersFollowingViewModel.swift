import SwiftUI
import FirebaseFirestore
import FirebaseFirestore

class FollowersFollowingViewModel: ObservableObject {
    @Published var users: [User] = []
    
    private let type: FollowType
    private var user: User?
    private var db = Firestore.firestore()
    
    init(user: User?, type: FollowType) {
        self.user = user
        self.type = type
    }
    
    func fetchUsers() {
        guard let user = user else { return }
        
        let ids = type == .followers ? user.followers : user.following
        
        let group = DispatchGroup()
        var fetchedUsers: [User] = []
        
        for id in ids {
            group.enter()
            db.collection("users").document(id).getDocument { document, error in
                defer { group.leave() }
                
                if let document = document, document.exists {
                    if let fetchedUser = try? document.data(as: User.self) {
                        fetchedUsers.append(fetchedUser)
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            self.users = fetchedUsers
        }
    }
    
    func removeUser(_ userToRemove: User) {
        guard let uid = user?.id else { return }
        
        let fieldToUpdate = type == .followers ? "followers" : "following"
        
        db.collection("users").document(uid).updateData([
            fieldToUpdate: FieldValue.arrayRemove([userToRemove.id])
        ]) { error in
            if let error = error {
                print("Failed to remove user: \(error.localizedDescription)")
                return
            }
            // Update local array
            if self.type == .followers {
                self.user?.followers.removeAll { $0 == userToRemove.id }
            } else {
                self.user?.following.removeAll { $0 == userToRemove.id }
            }
            self.fetchUsers() // Refresh the list
        }
    }
}
