//
//  wifi.swift
//  App
//
//  Created by Nigam Chaudhary on 23/02/25.
//

import SwiftUI

struct Wifi: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "admissionNumber") ?? ""
    @State private var password: String = UserDefaults.standard.string(forKey: "password") ?? ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Image(systemName: "wifi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.white)

                    Button(action: openWiFiLogin) {
                        Text("Connect")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(width: 200, height: 50)
                            .background(Color.orange)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }

                    Text("Note: Please Connect To ABESEC WiFi Network Before Pressing The Connect Button.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    NavigationLink(destination: Credentials()) {
                        Text("Credentials")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(width: 200, height: 50)
                            .background(Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .onAppear {
                    loadCredentials()
                }
            }
        }
    }

    func loadCredentials() {
        username = UserDefaults.standard.string(forKey: "admissionNumber") ?? ""
        password = UserDefaults.standard.string(forKey: "password") ?? ""
    }

    func openWiFiLogin() {
        let urlString = "https://192.168.1.254:8090/httpclient.html?username=\(username)&password=\(password)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    Wifi()
}
