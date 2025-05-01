import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        if isActive {
            ContentView() // This is your existing app entry point
        } else {
            VStack(spacing: 30) {
                Spacer()

                Image("tanbuzz")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(radius: 10)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0)) {
                            scale = 1.0
                            opacity = 1.0
                        }
                    }

                Text("TanBuzz")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundColor(.black)
                    .opacity(opacity)

                Spacer()

                Text("Developed by Nigam Chaudhary")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                    .opacity(opacity)
                    .padding(.bottom, 90) // Reduced the bottom padding to move it up
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                            opacity = 1.0
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
