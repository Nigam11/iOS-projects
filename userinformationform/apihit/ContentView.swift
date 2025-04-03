import SwiftUI

struct ContentView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var age: String = ""
    @State private var phoneNumber: String = ""
    @State private var address: String = ""
    @State private var isLoading: Bool = false
    @State private var showResponseScreen: Bool = false
    @State private var responseData: [String: Any] = [:]
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("User Information")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Group {
                    CustomTextField(placeholder: "Enter your name", text: $name)
                    CustomTextField(placeholder: "Enter your email", text: $email, keyboardType: .emailAddress)
                    CustomTextField(placeholder: "Enter your age", text: $age, keyboardType: .numberPad)
                    CustomTextField(placeholder: "Enter your phone number", text: $phoneNumber, keyboardType: .phonePad)
                    CustomTextField(placeholder: "Enter your address", text: $address)
                }
                .padding(.horizontal)

                Button(action: submitData) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                NavigationLink(destination: ResponseScreen(responseData: responseData), isActive: $showResponseScreen) {
                    EmptyView()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("🚀 Submit Your Details")
        }
    }
    
    func submitData() {
        if name.isEmpty || email.isEmpty || age.isEmpty || phoneNumber.isEmpty || address.isEmpty {
            alertMessage = "Please fill in all fields before submitting."
            showAlert = true
            return
        }
        
        isLoading = true
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["name": name, "email": email, "age": age, "phone": phoneNumber, "address": address]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data, var jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    jsonResponse = ["id": jsonResponse["id"] ?? 0, "name": name, "email": email, "age": age, "phone": phoneNumber, "address": address]
                    responseData = jsonResponse
                    showResponseScreen = true
                }
            }
        }.resume()
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 3)
            .keyboardType(keyboardType)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
