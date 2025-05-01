import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: EditProfileViewModel

    var user: User
    var onSave: (Bool) -> Void

    init(user: User, onSave: @escaping (Bool) -> Void) {
        self.user = user
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Group {
                    TextField("Name", text: $viewModel.name)
                    TextField("Username", text: $viewModel.username)
                    TextField("Bio", text: $viewModel.bio)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.horizontal)

                Toggle("Private Account", isOn: $viewModel.isPrivate)
                    .padding(.horizontal)
                    .toggleStyle(SwitchToggleStyle(tint: Color.blue))

                Spacer()

                Button("Save Changes") {
                    viewModel.saveChanges()
                    onSave(true)
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 6)
                .padding(.horizontal)
            }
            .padding(.top)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.85, green: 0.98, blue: 1.0), Color(red: 0.70, green: 0.92, blue: 1.0)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
