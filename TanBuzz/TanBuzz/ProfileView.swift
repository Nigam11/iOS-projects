import SwiftUI
import FirebaseAuth
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showLogoutConfirmation = false
    @State private var showAddAccountConfirmation = false
    @State private var showSaveConfirmation = false

    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImageFadeIn = false
    @State private var showPhotoPicker = false

    var body: some View {
        NavigationView {
            ZStack {
                // Updated Background: Soft light blue gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.85, green: 0.95, blue: 1.0), // #D9F2FF
                        Color(red: 0.70, green: 0.90, blue: 0.98)  // #B3E5FA
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    // Profile Picture
                    VStack {
                        Button {
                            showPhotoPicker = true
                        } label: {
                            if let profileImageUrl = viewModel.user?.profileImageURL,
                               let url = URL(string: profileImageUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .opacity(profileImageFadeIn ? 1 : 0)
                                            .onAppear {
                                                withAnimation(.easeIn(duration: 0.5)) {
                                                    profileImageFadeIn = true
                                                }
                                            }
                                    case .failure:
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top)

                        Text("Change Photo")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                showPhotoPicker = true
                            }
                    }
                    .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                profileImageFadeIn = false // Reset opacity
                                await viewModel.uploadProfileImage(uiImage)
                                await MainActor.run {
                                    withAnimation(.easeIn(duration: 0.5)) {
                                        profileImageFadeIn = true
                                    }
                                }
                            }
                        }
                    }

                    // Name, Username, Bio
                    VStack(spacing: 4) {
                        Text(viewModel.user?.name ?? "Name")
                            .font(.title2).bold()
                        Text("@\(viewModel.user?.username ?? "username")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(viewModel.user?.bio ?? "Bio...")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        if viewModel.user?.isPrivate == true {
                            Text("Private Account")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                        }

                        // Edit Profile Button
                        Button {
                            showEditProfile = true
                        } label: {
                            Text("Edit Profile")
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                                .frame(width: 140, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical)

                    // Followers and Following
                    HStack(spacing: 30) {
                        NavigationLink(destination: FollowersFollowingView(type: .followers, user: viewModel.user)) {
                            VStack {
                                Text("\(viewModel.user?.followers.count ?? 0)")
                                    .font(.headline)
                                Text("Followers")
                                    .font(.caption)
                            }
                        }

                        NavigationLink(destination: FollowersFollowingView(type: .following, user: viewModel.user)) {
                            VStack {
                                Text("\(viewModel.user?.following.count ?? 0)")
                                    .font(.headline)
                                Text("Following")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()

                    // Account Options
                    VStack(spacing: 12) {
                        Button {
                            showAddAccountConfirmation = true
                        } label: {
                            Text("Add Account")
                                .foregroundColor(.primary)
                                .font(.body)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                                )
                        }

                        Button {
                            showLogoutConfirmation = true
                        } label: {
                            Text("Logout")
                                .foregroundColor(.red)
                                .font(.body)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.shareProfile()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                if let user = viewModel.user {
                    EditProfileView(user: user) { didSave in
                        if didSave {
                            viewModel.fetchCurrentUser()
                            showSaveConfirmation = true
                        }
                    }
                }
            }
            .alert("Confirm Logout", isPresented: $showLogoutConfirmation) {
                Button("Logout", role: .destructive) {
                    viewModel.logout()
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Add New Account?", isPresented: $showAddAccountConfirmation) {
                Button("Add Account", role: .destructive) {
                    viewModel.logout()
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Profile Updated Successfully!", isPresented: $showSaveConfirmation) {
                Button("OK", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $viewModel.isLoggedOut) {
                LoginView()
            }
            .onAppear {
                viewModel.fetchCurrentUser()
            }
        }
    }
}
