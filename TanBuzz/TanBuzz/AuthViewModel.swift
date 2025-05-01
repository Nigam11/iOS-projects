import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isFromSignUp = false  // Prevents auto navigation during sign-up

    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()

    init() {
        self.userSession = Auth.auth().currentUser
        self.fetchUser()

        // Listener to track auth state changes
        Auth.auth().addStateDidChangeListener { _, user in
            if self.isFromSignUp {
                // Avoid navigation to MainTabView right after sign-up
                return
            }
            self.userSession = user
            if let user = user {
                self.fetchUser()
            } else {
                self.currentUser = nil
            }
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.userSession = result?.user
            self.fetchUser()
            completion(.success(()))
        }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        self.isFromSignUp = true

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.isFromSignUp = false
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                self.isFromSignUp = false
                completion(.failure(NSError(domain: "SignUpError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found after sign up."])))
                return
            }

            // Store default user data in Firestore
            let userData: [String: Any] = [
                "id": user.uid,
                "username": username,
                "name": "",
                "email": email,
                "bio": "",
                "profileImageURL": "",
                "isPrivate": false,
                "followers": [],
                "following": [],
                "location": ""
            ]

            self.db.collection("users").document(user.uid).setData(userData) { error in
                self.isFromSignUp = false
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    // MARK: - Fetch Current User
    func fetchUser() {
        guard let uid = userSession?.uid else { return }
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = try? snapshot?.data(as: User.self) {
                self.currentUser = data
            }
        }
    }

    // MARK: - Upload Profile Image
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No UID", code: 0)))
            return
        }

        let ref = Storage.storage().reference().child("profile_images/\(uid).jpg")

        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            completion(.failure(NSError(domain: "Image conversion failed", code: 0)))
            return
        }

        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let imageUrl = url?.absoluteString else {
                    completion(.failure(NSError(domain: "No URL", code: 0)))
                    return
                }

                Firestore.firestore().collection("users").document(uid).updateData([
                    "profileImageURL": imageUrl
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        DispatchQueue.main.async {
                            self.fetchUser()
                        }
                        completion(.success(()))
                    }
                }
            }
        }
    }

    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
