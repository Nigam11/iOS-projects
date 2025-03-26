//
//  Credentials.swift
//  connectify
//
//  Created by Nigam Chaudhary on 23/02/25.
//

import SwiftUI

struct Credentials: View {
    @Environment(\.presentationMode) var presentationMode  // Used to navigate back

    @AppStorage("admissionNumber") private var admissionNumber: String = ""
    @AppStorage("password") private var password: String = ""
    
    @State private var isPasswordVisible: Bool = false
    @State private var showAlert: Bool = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Image(systemName: "wifi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 50)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Text("WiFi Credentials")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Please enter your WiFi credentials")
                    .font(.body)
                    .foregroundColor(.gray)

                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                    TextField("Admission Number", text: $admissionNumber)
                        .foregroundColor(.white)
                        .textFieldStyle(PlainTextFieldStyle())
                        .disableAutocorrection(true)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .frame(width: 300)

                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)

                    if isPasswordVisible {
                        TextField("Password", text: $password)
                            .foregroundColor(.white)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Password", text: $password)
                            .foregroundColor(.white)
                    }

                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .frame(width: 300)

                Text("Note: Your credentials will only be saved locally on your phone.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Button(action: {
                    saveCredentials()
                }) {
                    Text("Save")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 200, height: 50)
                        .background(Color.orange)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Success"),
                        message: Text("Your credentials have been saved successfully."),
                        dismissButton: .default(Text("OK"), action: {
                            presentationMode.wrappedValue.dismiss()  // Dismiss the view
                        })
                    )
                }

                Text("'ABESEC' WiFi Password: 032abes459")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            }
            .padding()
        }
    }

    private func saveCredentials() {
        showAlert = true
    }
}

#Preview {
    Credentials()
}
