import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isFollowed: Bool = false
    @Published var isFollowRequestPending: Bool = false
    @Published var showRequestSentPopup: Bool = false

    private var db = Firestore.firestore()

    // Fetch the user's profile data
    func fetchUserProfile(userId: String) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot, let user = try? snapshot.data(as: User.self) {
                self.user = user
            }
        }
    }

    // Check the follow status of the current user
    func checkFollowStatus(userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        // Check if the current user is following the target user
        db.collection("users").document(currentUserId).getDocument { snapshot, error in
            if let error = error {
                print("Error checking follow status: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot, let currentUser = try? snapshot.data(as: User.self) {
                self.isFollowed = currentUser.following.contains(userId)
            }
        }

        // Check if a follow request is pending
        db.collection("followRequests")
            .whereField("senderId", isEqualTo: currentUserId)
            .whereField("receiverId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking follow request: \(error.localizedDescription)")
                    return
                }

                if let documents = snapshot?.documents, !documents.isEmpty {
                    self.isFollowRequestPending = true
                } else {
                    self.isFollowRequestPending = false
                }
            }
    }

    // Send a follow request to another user
    func sendFollowRequest(receiverId: String) {
        guard let senderId = Auth.auth().currentUser?.uid else { return }

        let followRequestRef = db.collection("followRequests").document()
        let notificationRef = db.collection("notifications").document()

        followRequestRef.setData([
            "senderId": senderId,
            "receiverId": receiverId,
            "status": "pending",
            "timestamp": Timestamp()
        ]) { error in
            if let error = error {
                print("Error sending follow request: \(error.localizedDescription)")
            } else {
                print("Follow request sent")
                self.isFollowRequestPending = true
                self.showRequestSentPopup = true // trigger popup

                // After follow request, create a notification for the receiver
                notificationRef.setData([
                    "id": notificationRef.documentID,
                    "senderId": senderId,
                    "receiverId": receiverId,
                    "type": "follow_request", // you can use this to filter
                    "timestamp": Timestamp(),
                    "isRead": false
                ]) { notificationError in
                    if let notificationError = notificationError {
                        print("Error creating notification: \(notificationError.localizedDescription)")
                    } else {
                        print("Notification created successfully")
                    }
                }
            }
        }
    }


    // Accept a follow request
    func acceptFollowRequest(requestId: String) {
        let requestRef = db.collection("followRequests").document(requestId)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let requestDoc = try transaction.getDocument(requestRef)

                guard let requestData = requestDoc.data(),
                      let senderId = requestData["senderId"] as? String,
                      let receiverId = requestData["receiverId"] as? String,
                      let status = requestData["status"] as? String,
                      status == "pending" else {
                    print("Invalid or already processed follow request")
                    return nil
                }

                // Update the follow request status to accepted
                transaction.updateData(["status": "accepted"], forDocument: requestRef)

                // Add the sender to the receiver's followers list
                let receiverRef = self.db.collection("users").document(receiverId)
                transaction.updateData([
                    "followers": FieldValue.arrayUnion([senderId])
                ], forDocument: receiverRef)

                // Add the receiver to the sender's following list
                let senderRef = self.db.collection("users").document(senderId)
                transaction.updateData([
                    "following": FieldValue.arrayUnion([receiverId])
                ], forDocument: senderRef)

                // Remove the receiver from the sender's pending follow requests
                transaction.updateData([
                    "pendingFollowRequests": FieldValue.arrayRemove([receiverId])
                ], forDocument: senderRef)

            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                print("Transaction fetch error: \(fetchError.localizedDescription)")
                return nil
            }
            return nil

        }, completion: { (_, error) in
            if let error = error {
                print("Error accepting follow request: \(error.localizedDescription)")
            } else {
                print("Follow request accepted successfully")
                self.isFollowed = true
                self.isFollowRequestPending = false
            }
        })
    }

    // Reject a follow request
    func rejectFollowRequest(requestId: String) {
        let requestRef = db.collection("followRequests").document(requestId)

        requestRef.delete { error in
            if let error = error {
                print("Error rejecting follow request: \(error.localizedDescription)")
            } else {
                print("Follow request rejected")
            }
        }
    }
}
