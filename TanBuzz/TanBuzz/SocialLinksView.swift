import SwiftUI

struct SocialLinksView: View {
    @Binding var socialLinks: [String: String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(socialLinks.keys.sorted(), id: \.self) { key in
                HStack {
                    Text(key.capitalized)
                        .font(.headline)
                        .foregroundColor(.black)

                    TextField("Enter \(key)", text: Binding(
                        get: { socialLinks[key, default: ""] },
                        set: { socialLinks[key] = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            }

            Button(action: {
                addNewSocialLink()
            }) {
                Text("Add New Social Link")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.98, blue: 1.0),
                    Color(red: 0.70, green: 0.92, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .ignoresSafeArea()
    }

    func addNewSocialLink() {
        let newKey = "Instagram"
        if socialLinks[newKey] == nil {
            socialLinks[newKey] = ""
        }
    }
}
