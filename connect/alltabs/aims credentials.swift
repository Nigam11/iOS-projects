//
//  AimsCredentials.swift
//  App
//
//  Created by Nigam Chaudhary on 23/02/25.
//

import SwiftUI

struct AimsCredentials: View {
    @State private var admissionNumber: String = UserDefaults.standard.string(forKey: "AdmissionNumber") ?? ""
    @State private var password: String = UserDefaults.standard.string(forKey: "Password") ?? ""
    @State private var isPasswordVisible: Bool = false
    @State private var showAlert: Bool = false  // Success message popup
    @Environment(\.dismiss) var dismiss  // Used to return to the Attendance page

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(systemName: "pencil.and.outline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.pink)
                
                Text("Aims Credentials")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                Text("Please enter your AIMS credentials")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                VStack(spacing: 15) {
                    CustomInputField(iconName: "person.fill", placeholder: "Admission Number", text: $admissionNumber, isSecure: false)
                    
                    CustomInputField(iconName: "lock.fill", placeholder: "Password", text: $password, isSecure: true, isPasswordVisible: $isPasswordVisible)
                }
                .padding(.horizontal, 30)
                
                Text("Note: Your Credentials Will Only Be Saved On Your Phone Locally.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Button(action: saveCredentials) {
                    Text("Save")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 200, height: 50)
                        .background(Color.orange)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
                .alert("Success", isPresented: $showAlert) {
                    Button("OK") {
                        dismiss()  // Automatically return to Attendance page
                    }
                } message: {
                    Text("Credentials saved successfully!")
                }
            }
            .padding()
        }
    }
    
    func saveCredentials() {
        UserDefaults.standard.set(admissionNumber, forKey: "AdmissionNumber")
        UserDefaults.standard.set(password, forKey: "Password")
        showAlert = true  // Show success popup
    }
}

struct CustomInputField: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool
    @Binding var isPasswordVisible: Bool

    init(iconName: String, placeholder: String, text: Binding<String>, isSecure: Bool, isPasswordVisible: Binding<Bool> = .constant(false)) {
        self.iconName = iconName
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self._isPasswordVisible = isPasswordVisible
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.gray)
            
            if isSecure {
                if isPasswordVisible {
                    TextField(placeholder, text: $text)
                        .foregroundColor(.white)
                } else {
                    SecureField(placeholder, text: $text)
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    AimsCredentials()
}
