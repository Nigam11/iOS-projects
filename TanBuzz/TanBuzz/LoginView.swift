import SwiftUI
import Firebase

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var loginError: String? = nil
    @State private var isLoading = false
    @State private var showMainTabView = false
    @State private var animateTransition = false

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            NavigationStack {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Spacer().frame(height: 30)
                        Image(systemName: "circle.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color.blue.opacity(0.6))

                        Text("Welcome Back!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)

                        Text("Log in to your account")
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

                    // Email Field
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Color.gray)
                        TextField("Email address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .font(.system(size: 16))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                    .padding(.horizontal)

                    // Password Field
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color.gray)
                        SecureField("Password", text: $password)
                        Image(systemName: "eye")
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                    .padding(.horizontal)

                    // Loading or Login Button
                    Button(action: {
                        loginUser()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Log In")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(14)
                        }
                    }
                    .disabled(isLoading)
                    .padding(.horizontal)

                    // Error message
                    if let error = loginError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 4)
                            .padding(.horizontal)
                    }

                    Spacer()

                    // Navigation links
                    VStack(spacing: 8) {
                        NavigationLink(destination: SignUpView()) {
                            Text("Don't have an account? Sign Up")
                                .font(.footnote)
                                .foregroundColor(Color.blue)
                        }

                        NavigationLink(destination: ForgotPasswordView()) {
                            Text("Forgot Password?")
                                .font(.footnote)
                                .foregroundColor(Color.blue)
                        }
                    }
                    .padding(.bottom, 16)
                }
                .navigationBarTitle("Login", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
            }

            // Success animation
            if showMainTabView {
                ZStack {
                    Color.white.ignoresSafeArea()

                    VStack {
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color.blue.opacity(0.8))
                            .scaleEffect(animateTransition ? 1.2 : 0.5)
                            .opacity(animateTransition ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5), value: animateTransition)

                        Text("Welcome!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.blue.opacity(0.8))
                            .opacity(animateTransition ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.1), value: animateTransition)
                    }
                }
                .transition(.opacity)
                .onAppear {
                    animateTransition = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        showMainTabView = false
                        isLoading = false
                    }
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { showMainTabView == false && animateTransition == true },
            set: { _ in }
        )) {
            MainTabView()
                .environmentObject(authViewModel)
        }
    }

    func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            loginError = "Please enter both email and password."
            return
        }

        isLoading = true

        authViewModel.signIn(email: email, password: password) { result in
            switch result {
            case .success():
                loginError = nil
                print("✅ User logged in successfully")

                // Animate and present main tab
                withAnimation(.easeInOut(duration: 0.4)) {
                    showMainTabView = true
                }

            case .failure(let error):
                loginError = "Error logging in: \(error.localizedDescription)"
                print("⚠️ Login Error: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
}
