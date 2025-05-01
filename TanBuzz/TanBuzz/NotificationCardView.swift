import SwiftUI

enum NotificationType: Codable {
    case followRequest
    case like
}

struct NotificationCardView: View {
    var notification: NotificationModel
    var acceptAction: () -> Void
    var rejectAction: () -> Void

    @State private var isVisible = true
    @State private var navigateToUserProfile = false

    private var notificationTitle: String {
        switch notification.type {
        case .followRequest:
            return "Follow Request"
        case .like:
            return "Like"
        }
    }

    var body: some View {
        if isVisible {
            VStack(spacing: 16) {
                Text(notificationTitle)
                    .font(.title3.bold())
                    .padding(.top)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 12) {
                    // Profile + Message
                    Button(action: {
                        navigateToUserProfile = true
                    }) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text((notification.senderId ?? "").prefix(2))
                                        .font(.headline)
                                        .foregroundColor(.black)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text("New follow request")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("From user: \((notification.senderId ?? "").prefix(8))...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    // Accept Button
                    Button("Accept") {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            isVisible = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            acceptAction()
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)

                    // Reject Button
                    Button("Reject") {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            isVisible = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            rejectAction()
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 4)
                )
                .padding(.horizontal)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            .background(
                NavigationLink(destination: UserProfileView(userId: notification.senderId ?? ""), isActive: $navigateToUserProfile) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
}
