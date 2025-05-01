import SwiftUI

struct NotificationListView: View {
    @StateObject var viewModel = NotificationViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.98, blue: 1.0),
                    Color(red: 0.70, green: 0.92, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Notifications")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.notifications) { notification in
                            NotificationCardView(
                                notification: notification,
                                acceptAction: {
                                    if let notificationId = notification.id {
                                        viewModel.updateFollowRequest(notificationId: notificationId, accept: true)
                                    }
                                },
                                rejectAction: {
                                    if let notificationId = notification.id {
                                        viewModel.updateFollowRequest(notificationId: notificationId, accept: false)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
                .onAppear {
                    viewModel.fetchNotifications()
                }
            }
        }
    }
}
