//
//  qa_page.swift
//  App
//
//  Created by Nigam Chaudhary on 23/02/25.
//

import SwiftUI

struct QA_Page: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                // Q&A Title
                Text("")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .padding(.top, 50)

                Spacer()

                // Coming Soon Text
                Text(" New Update Coming Soon.")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)

                Spacer()

                // Developer Information
                VStack(spacing: 8) {
                    Text("Nigam Chaudhary")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("AIML 3rd Year, ABESEC")
                        .font(.body)
                        .foregroundColor(.gray)

                    // Social Media Icons
                    HStack(spacing: 30) {
                        // Instagram Button
                        Button(action: {
                            if let instagramURL = URL(string: "https://www.instagram.com/jass__chaudhary_?igsh=MXd4Y3IyaHY3aXpwbg==") {
                                UIApplication.shared.open(instagramURL)
                            }
                        }) {
                            Image(systemName: "camera.aperture") // SF Symbol alternative
                                .font(.system(size: 50))
                                .foregroundColor(Color.pink)
                        }

                        // LinkedIn Button
                        Button(action: {
                            if let linkedinURL = URL(string: "https://www.linkedin.com/in/nigam-chaudhary-b578a3271") {
                                UIApplication.shared.open(linkedinURL)
                            }
                        }) {
                            Image(systemName: "link.circle.fill") // SF Symbol alternative
                                .font(.system(size: 50))
                                .foregroundColor(Color.blue)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    QA_Page()
}
