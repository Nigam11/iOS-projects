import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var messageText: String = ""
    var chatId: String?
    var otherUserId: String

    init(chatId: String?, otherUserId: String) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(chatId: chatId, otherUserId: otherUserId))
        self.chatId = chatId
        self.otherUserId = otherUserId
    }

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

            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            HStack {
                                if message.senderId == viewModel.currentUserID {
                                    Spacer()
                                    Text(message.content)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                } else {
                                    Text(message.content)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.top)
                }

                HStack {
                    TextField("Message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(minHeight: 30)

                    Button(action: {
                        viewModel.sendMessage(content: messageText)
                        messageText = ""
                    }) {
                        Text("Send")
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 4)
                .padding()
            }
            .onAppear {
                viewModel.fetchMessages()
            }
        }
        .navigationTitle(viewModel.otherUserName.isEmpty ? "Chat" : "Chat with \(viewModel.otherUserName)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
