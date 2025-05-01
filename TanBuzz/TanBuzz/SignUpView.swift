import SwiftUI

struct SignUpView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var agreedToTerms = false

    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 25) {
            // Header with Circle Icon
            VStack(spacing: 8) {
                Spacer().frame(height: 30)
                Image(systemName: "circle.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.blue.opacity(0.6))
                Text("Create an Account")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                Text("Sign up to get started")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
            .cornerRadius(20)
            .padding(.horizontal)

            // Username
            HStack {
                Image(systemName: "person")
                    .foregroundColor(.gray)
                TextField("Username", text: $username)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
            .padding(.horizontal)

            // Email
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.gray)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
            .padding(.horizontal)

            // Password
            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.gray)
                SecureField("Password", text: $password)
                Image(systemName: "eye")
                    .foregroundColor(.gray.opacity(0.3))
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
            .padding(.horizontal)

            // Terms checkbox
            HStack {
                Button(action: {
                    agreedToTerms.toggle()
                }) {
                    Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                        .foregroundColor(agreedToTerms ? .blue : .gray)
                        .font(.title2)
                }

                Text("I agree to the Terms & Conditions")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)

            // Continue Button
            Button(action: {
                isLoading = true
                authViewModel.signUp(email: email, password: password, username: username) { result in
                    isLoading = false
                    switch result {
                    case .success:
                        showSuccessAlert = true
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Continue")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(agreedToTerms ? Color.blue : Color.gray)
                        .cornerRadius(14)
                }
            }
            .disabled(!agreedToTerms || isLoading)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .alert("Account Created Successfully", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}
