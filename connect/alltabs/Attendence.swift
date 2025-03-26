import SwiftUI
import WebKit

struct Attendance: View {
    @State private var admissionNumber: String = UserDefaults.standard.string(forKey: "AdmissionNumber") ?? ""
    @State private var password: String = UserDefaults.standard.string(forKey: "Password") ?? ""
    @State private var showWebView = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)

                    Text("Click the Attendance button to open AIMS portal.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    Button(action: { showWebView = true }) {
                        Text("Attendance")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 250, height: 60)
                            .background(Color.orange)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showWebView) {
                        WebView(url: URL(string: "https://abes.web.simplifii.com/index.php")!,
                                username: admissionNumber,
                                password: password)
                    }

                    Text("Ensure to fill in your credentials before proceeding.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    NavigationLink(destination: AimsCredentials()) {
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
            }
            .onAppear { fetchStoredCredentials() }
        }
    }

    func fetchStoredCredentials() {
        admissionNumber = UserDefaults.standard.string(forKey: "AdmissionNumber") ?? ""
        password = UserDefaults.standard.string(forKey: "Password") ?? ""
    }
}

/// **WebView with Auto-Login**
struct WebView: UIViewRepresentable {
    let url: URL
    let username: String
    let password: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ Webpage Loaded. Injecting JavaScript...")

            let js = """
            setTimeout(function() {
                var userField = document.querySelector('input[name="username"], input[id="username"], input[type="text"]');
                var passField = document.querySelector('input[name="password"], input[id="password"], input[type="password"]');
                var loginButton = document.querySelector('button[type="submit"], input[type="submit"], button');

                if (userField && passField) {
                    userField.value = '\(parent.username)';
                    passField.value = '\(parent.password)';
                    console.log('✅ Auto-filled credentials.');

                    if (loginButton) {
                        loginButton.click();
                        console.log('✅ Auto-login executed.');
                    } else {
                        console.log('⚠️ Login button not found.');
                    }
                } else {
                    console.log('❌ Username or password field not found.');
                }
            }, 3000);
            """
            
            webView.evaluateJavaScript(js) { result, error in
                if let error = error {
                    print("❌ JavaScript injection failed: \(error.localizedDescription)")
                } else {
                    print("✅ JavaScript executed successfully.")
                }
            }
        }
    }
}

#Preview {
    Attendance()
}
