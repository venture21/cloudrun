import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Connection error banner
            if let error = viewModel.connectionError {
                Text("Connection error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.2))
            }
            
            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            // Input area
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isInputFocused)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(viewModel.isLoading ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(viewModel.isLoading || messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .navigationTitle("Gemini Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        viewModel.sendMessage(trimmedMessage)
        messageText = ""
    }
}

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .foregroundColor(message.isUser ? .white : .primary)
                    .background(message.isUser ? Color.blue : Color(.systemGray5))
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
                
                Text(message.displayTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}