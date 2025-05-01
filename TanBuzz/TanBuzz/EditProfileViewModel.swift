import SwiftUI
import FirebaseFirestore
import FirebaseStorage

class EditProfileViewModel: ObservableObject {
    @Published var name: String
    @Published var username: String
    @Published var bio: String
    @Published var socialLinks: [String]
    @Published var profileImage: UIImage?
    @Published var isPrivate: Bool  // Add a property for the private account toggle
    
    private var user: User?
    
    init(user: User?) {
        self.user = user
        self.name = user?.name ?? ""
        self.username = user?.username ?? ""
        self.bio = user?.bio ?? ""
        self.isPrivate = user?.isPrivate ?? false  // Default to false if nil
        
        if let linksDict = user?.socialLinks {
            self.socialLinks = linksDict.map { "\($0.key): \($0.value)" }
        } else {
            self.socialLinks = []
        }
    }
    
    func saveChanges() {
        guard let uid = user?.id else { return }
        let db = Firestore.firestore()
        
        var socialLinksDict: [String: String] = [:]
        for link in socialLinks {
            let components = link.split(separator: ":").map { String($0) }
            if components.count == 2 {
                socialLinksDict[components[0]] = components[1]
            }
        }
        
        var data: [String: Any] = [
            "name": name,
            "username": username,
            "bio": bio,
            "socialLinks": socialLinksDict,
            "isPrivate": isPrivate
        ]
        
        db.collection("users").document(uid).updateData(data) { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                print("Profile updated successfully.")
            }
        }
    

        // Handle image upload asynchronously
        if let image = profileImage {
            uploadProfileImage(image) { url in
                // Set the profile image URL only after the upload is successful
                data["profileImageURL"] = url?.absoluteString ?? ""
                db.collection("users").document(uid).updateData(data) { error in
                    if let error = error {
                        print("Error updating profile: \(error.localizedDescription)")
                    } else {
                        print("Profile updated successfully.")
                    }
                }
            }
        } else {
            // No image, directly update data
            db.collection("users").document(uid).updateData(data) { error in
                if let error = error {
                    print("Error updating profile: \(error.localizedDescription)")
                } else {
                    print("Profile updated successfully.")
                }
            }
        }
    }
    
    private func uploadProfileImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let uid = user?.id,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading profile image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL(completion: { url, _ in
                completion(url)
            })
        }
    }
}
