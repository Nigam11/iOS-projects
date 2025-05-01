import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var isLoading = false
    @State private var message: String?
    @State private var isMessageSuccess = false

    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Spacer().frame(height: 40)

                // Logo placeholder (Optional)
                Image(systemName: "circle.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.blue.opacity(0.6))

                Text("Forgot Password")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)

                Text("Enter your email to reset your password")
                    .foregroundColor(.gray)
                    .font(.subheadline)

                // Email input field
                TextField("Enter your email", text: $email)
                    .padding()
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                    .padding(.horizontal)

                // Message display
                if let message = message {
                    Text(message)
                        .foregroundColor(isMessageSuccess ? .green : .red)
                        .padding()
                        .font(.footnote)
                }

                // Loading or Button
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .padding()
                } else {
                    Button(action: resetPassword) {
                        Text("Reset Password")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
            .cornerRadius(20)
            .padding(.horizontal)
            .navigationBarTitle("Forgot Password", displayMode: .inline)
        }
    }

    func resetPassword() {
        guard !email.isEmpty else {
            message = "Please enter your email."
            isMessageSuccess = false
            return
        }

        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            isLoading = false
            
            if let error = error {
                if let authError = error as? NSError {
                    if authError.code == AuthErrorCode.userNotFound.rawValue {
                        message = "No account found for this email address."
                        isMessageSuccess = false
                    } else {
                        message = authError.localizedDescription
                        isMessageSuccess = false
                    }
                }
            } else {
                message = "Password reset email sent! Please check your inbox."
                isMessageSuccess = true
            }
        }
    }
}

