//
//  Quiz.swift
//  App
//
//  Created by Nigam Chaudhary on 23/02/25.
//

import SwiftUI
import WebKit

struct Quiz: View {
    @State private var showWebView = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Full black background
            
            VStack(spacing: 30) {
                Spacer()
                
                // Quiz Logo with "?" and "Quiz" in the required style
                VStack(spacing: -20) {
                    Text("?")
                        .font(.system(size: 130, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Quiz")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Quiz Link Button
                Button(action: {
                    showWebView = true
                }) {
                    Text("Quiz link")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 200, height: 50)
                        .background(Color.orange)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }

                // Instruction Text
                Text("Click the button to Start Quiz")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showWebView) {
            webView(url: URL(string: "https://quiz.abesaims.site/")!)
        }
    }
}

// WebView Component to Load Website
struct webView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

#Preview {
    Quiz()
}
