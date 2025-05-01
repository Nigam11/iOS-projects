import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoggedOut = false
    @Published var showSaveConfirmation = false
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // Fetch the current user's data
    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot {
                do {
                    self.user = try snapshot.data(as: User.self)
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Fetch user data for another user (based on userId)
    func fetchUserData(userId: String, completion: @escaping (User?, Error?) -> Void) {
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let document = document, document.exists {
                do {
                    // Safely unwrap the optional returned by data(as:) into the 'user' variable
                    let user = try document.data(as: User.self)
                    completion(user, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
            }
        }
    }

    // Logout function
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedOut = true
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    // Share profile function
    func shareProfile() {
        guard let user = user else { return }
        let profileURL = "https://www.tanbuzz.com/\(user.username)"
        let shareText = "Check out my profile on TanBuzz: \(profileURL)"
        
        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController {
            
            let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = topVC.view
            topVC.present(activityVC, animated: true, completion: nil)
        }
    }
    
    // Upload new profile picture
    func uploadProfileImage(_ image: UIImage) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }

        let ref = storage.reference().child("profile_images/\(uid).jpg")
        
        do {
            _ = try await ref.putDataAsync(imageData)
            let url = try await ref.downloadURL()
            
            let urlString = url.absoluteString
            try await db.collection("users").document(uid).updateData([
                "profileImageURL": urlString
            ])
            
            await fetchCurrentUser()  // Refresh the user after updating image
        } catch {
            print("Error uploading profile image: \(error.localizedDescription)")
        }
    }
}
